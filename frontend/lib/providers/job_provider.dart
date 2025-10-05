import 'package:flutter/material.dart';
import '../models/job_model.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class JobProvider extends ChangeNotifier {
  List<JobModel> _jobs = [];
  List<JobModel> _featuredJobs = [];
  List<JobModel> _savedJobs = [];
  JobModel? _selectedJob;  // Add this
  
  bool _isLoading = false;
  String? _error;

  List<JobModel> get jobs => _jobs;
  List<JobModel> get featuredJobs => _featuredJobs;
  List<JobModel> get savedJobs => _savedJobs;
  JobModel? get selectedJob => _selectedJob;  // Add this
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchFeaturedJobs() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService().get(ApiConstants.featuredJobs);
      if (response.data['success']) {
        _featuredJobs = (response.data['jobs'] as List)
            .map((job) => JobModel.fromJson(job))
            .toList();
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load featured jobs';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchJobs() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService().get(ApiConstants.jobs);
      if (response.data['success']) {
        _jobs = (response.data['jobs'] as List)
            .map((job) => JobModel.fromJson(job))
            .toList();
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load jobs';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add this method
  Future<void> fetchJobById(String jobId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService().get('${ApiConstants.jobs}/$jobId');
      if (response.data['success']) {
        _selectedJob = JobModel.fromJson(response.data['job']);
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load job details';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveJob(String jobId) async {
    try {
      final response = await ApiService().post(ApiConstants.saveJob(jobId));
      if (response.data['success']) {
        await fetchSavedJobs();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> unsaveJob(String jobId) async {
    try {
      final response = await ApiService().delete(ApiConstants.saveJob(jobId));
      if (response.data['success']) {
        _savedJobs.removeWhere((job) => job.id == jobId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> fetchSavedJobs() async {
    try {
      final response = await ApiService().get(ApiConstants.savedJobs);
      if (response.data['success']) {
        _savedJobs = (response.data['savedJobs'] as List)
            .map((job) => JobModel.fromJson(job))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to load saved jobs';
    }
  }

  // Add this method
  bool isJobSaved(String jobId) {
    return _savedJobs.any((job) => job.id == jobId);
  }
}