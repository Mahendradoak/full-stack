import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../widgets/job_card.dart';
import '../widgets/loading_widget.dart';
import 'job_details_screen.dart';

class SavedJobsScreen extends StatelessWidget {
  const SavedJobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Jobs'),
      ),
      body: RefreshIndicator(
        onRefresh: () => jobProvider.fetchSavedJobs(),
        child: jobProvider.isLoading
            ? const LoadingWidget(message: 'Loading saved jobs...')
            : jobProvider.savedJobs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bookmark_border, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text(
                          'No Saved Jobs',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Jobs you save will appear here',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: jobProvider.savedJobs.length,
                    itemBuilder: (context, index) {
                      final job = jobProvider.savedJobs[index];
                      return JobCard(
                        job: job,
                        isSaved: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => JobDetailsScreen(jobId: job.id),
                            ),
                          );
                        },
                        onSave: () async {
                          await jobProvider.unsaveJob(job.id);
                        },
                      );
                    },
                  ),
      ),
    );
  }
}