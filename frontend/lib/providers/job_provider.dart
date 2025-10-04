import 'package:flutter/material.dart';
import '../models/job_model.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class JobProvider extends ChangeNotifier {
  List<JobModel> _jobs = [];
  List<JobModel> _featuredJobs = [];
  List<JobModel> _savedJobs = [];
  
  bool _isLoading = false;
  String? _error;
  
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = true;

  List<JobModel> get jobs => _jobs;
  List<JobModel> get featuredJobs => _featuredJobs;
  List<JobModel> get savedJobs => _savedJobs;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  Future<void> fetchFeaturedJobs() async {
    _isLoading = true;
    _error = null;
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

  Future<void> fetchJobs({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _jobs = [];
      _hasMore = true;
    }

    if (!_hasMore && !refresh) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService().get(
        ApiConstants.jobs,
        queryParameters: {'page': _currentPage, 'limit': 10},
      );

      if (response.data['success']) {
        final newJobs = (response.data['jobs'] as List)
            .map((job) => JobModel.fromJson(job))
            .toList();

        if (refresh) {
          _jobs = newJobs;
        } else {
          _jobs.addAll(newJobs);
        }

        _totalPages = response.data['pages'] ?? 1;
        _currentPage++;
        _hasMore = _currentPage <= _totalPages;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load jobs';
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

  Future<void> searchJobs(String keyword) async {
    await fetchJobs(refresh: true);
  }

  void clearFilters() {
    fetchJobs(refresh: true);
  }
}