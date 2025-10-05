import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../widgets/job_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart' as custom_widgets;
import 'job_details_screen.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load jobs only once when screen is first displayed
    if (!_isInitialized) {
      _isInitialized = true;
      _loadJobs();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadJobs() async {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    
    // Only fetch if we don't have jobs already
    if (jobProvider.jobs.isEmpty) {
      print('JobsScreen: Loading jobs...');
      await jobProvider.fetchJobs(refresh: true);
      print('JobsScreen: Jobs loaded: ${jobProvider.jobs.length}');
    } else {
      print('JobsScreen: Jobs already loaded: ${jobProvider.jobs.length}');
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final jobProvider = Provider.of<JobProvider>(context, listen: false);
      if (!jobProvider.isLoadingMore && jobProvider.hasMore) {
        print('JobsScreen: Loading more jobs...');
        jobProvider.fetchJobs();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context);
    
    // Debug info
    print('JobsScreen: Building with ${jobProvider.jobs.length} jobs');
    print('JobsScreen: isLoading=${jobProvider.isLoading}, error=${jobProvider.error}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Jobs'),
        actions: [
          // Show job count in app bar for debugging
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${jobProvider.jobs.length} jobs',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search jobs...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          jobProvider.clearSearch();
                          setState(() {});
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                jobProvider.searchJobs(value);
                setState(() {});
              },
            ),
          ),

          // Jobs List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                print('JobsScreen: Pull to refresh');
                await jobProvider.fetchJobs(refresh: true);
              },
              child: Builder(
                builder: (context) {
                  // Loading state (only show if no jobs yet)
                  if (jobProvider.isLoading && jobProvider.jobs.isEmpty) {
                    print('JobsScreen: Showing loading widget');
                    return const LoadingWidget(message: 'Loading jobs...');
                  }

                  // Error state (only show if no jobs and there's an error)
                  if (jobProvider.error != null && jobProvider.jobs.isEmpty) {
                    print('JobsScreen: Showing error: ${jobProvider.error}');
                    return custom_widgets.CustomErrorWidget(
                      message: jobProvider.error!,
                      onRetry: () {
                        print('JobsScreen: Retry button pressed');
                        jobProvider.fetchJobs(refresh: true);
                      },
                    );
                  }

                  // Empty state
                  if (jobProvider.jobs.isEmpty) {
                    print('JobsScreen: Showing empty state');
                    return _buildEmptyState(jobProvider);
                  }

                  // Jobs list with data
                  print('JobsScreen: Showing ${jobProvider.jobs.length} jobs');
                  return ListView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: jobProvider.jobs.length + 1,
                    itemBuilder: (context, index) {
                      // Loading more indicator
                      if (index == jobProvider.jobs.length) {
                        if (!jobProvider.hasMore) {
                          return Padding(
                            padding: const EdgeInsets.all(24),
                            child: Center(
                              child: Text(
                                'No more jobs to load',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                          );
                        }

                        if (jobProvider.isLoadingMore) {
                          return const Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        return const SizedBox(height: 24);
                      }

                      final job = jobProvider.jobs[index];
                      return JobCard(
                        job: job,
                        isSaved: jobProvider.isJobSaved(job.id),
                        onTap: () {
                          print('JobsScreen: Opening job ${job.id}');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => JobDetailsScreen(jobId: job.id),
                            ),
                          );
                        },
                        onSave: () async {
                          final isSaved = jobProvider.isJobSaved(job.id);
                          print('JobsScreen: ${isSaved ? "Unsaving" : "Saving"} job ${job.id}');
                          
                          final success = isSaved
                              ? await jobProvider.unsaveJob(job.id)
                              : await jobProvider.saveJob(job.id);

                          if (mounted && success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isSaved
                                      ? 'Job removed from saved'
                                      : 'Job saved successfully',
                                ),
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(JobProvider jobProvider) {
    final isSearching = jobProvider.searchQuery.isNotEmpty;

    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSearching ? Icons.search_off : Icons.work_off_outlined,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                isSearching ? 'No Jobs Found' : 'No Jobs Available',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isSearching
                    ? 'Try different search terms'
                    : 'Pull down to refresh or check your connection',
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              if (isSearching) ...[
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    _searchController.clear();
                    jobProvider.clearSearch();
                  },
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear Search'),
                ),
              ],
              if (!isSearching) ...[
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    print('JobsScreen: Manual refresh button pressed');
                    jobProvider.fetchJobs(refresh: true);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh Jobs'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}