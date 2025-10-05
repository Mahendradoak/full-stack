import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../widgets/job_card.dart';
import '../widgets/loading_widget.dart';
import 'job_details_screen.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Jobs'),
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
                          setState(() {});
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),

          // Jobs List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => jobProvider.fetchJobs(),
              child: jobProvider.isLoading && jobProvider.jobs.isEmpty
                  ? const LoadingWidget(message: 'Loading jobs...')
                  : jobProvider.jobs.isEmpty
                      ? const Center(child: Text('No jobs found'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: jobProvider.jobs.length,
                          itemBuilder: (context, index) {
                            final job = jobProvider.jobs[index];
                            return JobCard(
                              job: job,
                              isSaved: jobProvider.isJobSaved(job.id),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => JobDetailsScreen(jobId: job.id),
                                  ),
                                );
                              },
                              onSave: () async {
                                if (jobProvider.isJobSaved(job.id)) {
                                  await jobProvider.unsaveJob(job.id);
                                } else {
                                  await jobProvider.saveJob(job.id);
                                }
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
}