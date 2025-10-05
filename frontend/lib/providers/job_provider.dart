import 'package:flutter/material.dart';
import '../models/job_model.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class JobProvider extends ChangeNotifier {
  List<JobModel> _jobs = [];
  List<JobModel> _featuredJobs = [];
  List<JobModel> _savedJobs = [];
  JobModel? _selectedJob;
  
  bool _isLoading = false;
  bool _isLoadingMore = false;  // ADD THIS
  String? _error;
  
  // ADD THESE FOR SEARCH
  String _searchQuery = '';
  List<JobModel> _filteredJobs = [];
  
  // ADD THESE FOR PAGINATION
  int _currentPage = 1;
  bool _hasMore = true;

  // EXISTING GETTERS
  List<JobModel> get jobs => _searchQuery.isEmpty ? _jobs : _filteredJobs;  // MODIFIED
  List<JobModel> get featuredJobs => _featuredJobs;
  List<JobModel> get savedJobs => _savedJobs;
  JobModel? get selectedJob => _selectedJob;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // ADD THESE NEW GETTERS
  bool get isLoadingMore => _isLoadingMore;
  String get searchQuery => _searchQuery;
  bool get hasMore => _hasMore;

  // ADD THIS METHOD - Search functionality
  void searchJobs(String query) {
    _searchQuery = query.trim().toLowerCase();
    
    if (_searchQuery.isEmpty) {
      _filteredJobs = [];
    } else {
      _filteredJobs = _jobs.where((job) {
        return job.title.toLowerCase().contains(_searchQuery) ||
               job.company.toLowerCase().contains(_searchQuery) ||
               job.description.toLowerCase().contains(_searchQuery) ||
               job.location.toLowerCase().contains(_searchQuery);
      }).toList();
    }
    
    notifyListeners();
  }

  // ADD THIS METHOD - Clear search
  void clearSearch() {
    _searchQuery = '';
    _filteredJobs = [];
    notifyListeners();
  }

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

  // MODIFY THIS METHOD - Add refresh parameter
  Future<void> fetchJobs({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _jobs.clear();
    }

    if (!_hasMore || _isLoading || _isLoadingMore) return;

    if (refresh || _jobs.isEmpty) {
      _isLoading = true;
    } else {
      _isLoadingMore = true;
    }
    
    notifyListeners();

    try {
      final response = await ApiService().get(ApiConstants.jobs);
      if (response.data['success']) {
        final newJobs = (response.data['jobs'] as List)
            .map((job) => JobModel.fromJson(job))
            .toList();
        
        if (refresh) {
          _jobs = newJobs;
        } else {
          _jobs.addAll(newJobs);
        }
        
        _hasMore = newJobs.length >= 10;
        _currentPage++;
      }
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load jobs';
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

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

  bool isJobSaved(String jobId) {
    return _savedJobs.any((job) => job.id == jobId);
  }
}