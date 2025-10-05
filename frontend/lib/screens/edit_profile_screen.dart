import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../utils/constants.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _resumeLinkController = TextEditingController();
  final _skillController = TextEditingController();
  
  List<String> _skills = [];
  bool _hasChanges = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  void _loadUserData() {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      _nameController.text = user.name;
      _bioController.text = user.bio;
      _resumeLinkController.text = user.resumeLink;
      _skills = List.from(user.skills);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _resumeLinkController.dispose();
    _skillController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _markChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.warning),
            SizedBox(width: 12),
            Text('Discard Changes?'),
          ],
        ),
        content: const Text(
          'You have unsaved changes. Are you sure you want to discard them?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep Editing'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.updateProfile(
      name: _nameController.text.trim(),
      bio: _bioController.text.trim(),
      resumeLink: _resumeLinkController.text.trim(),
      skills: _skills,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Profile updated successfully'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(authProvider.error ?? 'Failed to update profile'),
              ),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _addSkill() {
    final skill = _skillController.text.trim();
    if (skill.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a skill'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_skills.contains(skill)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Skill already added'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _skills.add(skill);
      _skillController.clear();
    });
    _markChanged();

    // Animate the skill addition
    _animationController.forward(from: 0);
  }

  void _removeSkill(String skill) {
    setState(() {
      _skills.remove(skill);
    });
    _markChanged();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed "$skill"'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _skills.add(skill);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return PopScope(
      canPop: !_hasChanges,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && mounted) {
            context.pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
          actions: [
            if (_hasChanges)
              TextButton.icon(
                onPressed: authProvider.isLoading ? null : _saveProfile,
                icon: const Icon(Icons.check),
                label: const Text('Save'),
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Form(
            key: _formKey,
            onChanged: _markChanged,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Picture Section
                _buildProfilePictureSection(),
                const SizedBox(height: AppDimensions.paddingXLarge),

                // Personal Information
                _buildSectionHeader('Personal Information'),
                const SizedBox(height: AppDimensions.paddingMedium),

                CustomTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required';
                    }
                    if (value.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.paddingMedium),

                // Bio Field with Character Counter
                _buildBioField(),
                const SizedBox(height: AppDimensions.paddingLarge),

                // Resume Link
                _buildSectionHeader('Professional Details'),
                const SizedBox(height: AppDimensions.paddingMedium),

                CustomTextField(
                  controller: _resumeLinkController,
                  label: 'Resume Link',
                  hint: 'https://example.com/resume.pdf',
                  prefixIcon: Icons.link,
                  keyboardType: TextInputType.url,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (!value.startsWith('http://') &&
                          !value.startsWith('https://')) {
                        return 'Please enter a valid URL';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.paddingLarge),

                // Skills Section
                _buildSectionHeader('Skills & Expertise'),
                const SizedBox(height: AppDimensions.paddingMedium),

                _buildSkillsInput(),
                const SizedBox(height: AppDimensions.paddingMedium),

                _buildSkillsDisplay(),
                const SizedBox(height: AppDimensions.paddingXLarge),

                // Action Buttons
                _buildActionButtons(authProvider),
                const SizedBox(height: AppDimensions.paddingLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection() {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Hero(
                tag: 'profile_avatar',
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary,
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _nameController.text.isNotEmpty
                          ? _nameController.text[0].toUpperCase()
                          : user?.name[0].toUpperCase() ?? 'U',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Material(
                  color: AppColors.primary,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Photo upload coming soon!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    customBorder: const CircleBorder(),
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          Text(
            'Tap to change photo',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: _bioController,
          label: 'Bio',
          hint: 'Tell us about yourself...',
          prefixIcon: Icons.info_outline,
          keyboardType: TextInputType.multiline,
          validator: (value) {
            if (value != null && value.length > 500) {
              return 'Bio must be less than 500 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${_bioController.text.length}/500',
            style: TextStyle(
              fontSize: 12,
              color: _bioController.text.length > 500
                  ? AppColors.error
                  : Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsInput() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.warning,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Add your skills',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingSmall),
            Text(
              'Add skills one at a time. Press Enter or tap + to add.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _skillController,
                    decoration: InputDecoration(
                      hintText: 'e.g., Flutter, Design, Management',
                      prefixIcon: const Icon(Icons.code),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onSubmitted: (_) => _addSkill(),
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingSmall),
                FloatingActionButton.small(
                  onPressed: _addSkill,
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsDisplay() {
    if (_skills.isEmpty) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.code_off,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: AppDimensions.paddingSmall),
                Text(
                  'No skills added yet',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Skills (${_skills.length})',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (_skills.isNotEmpty)
                  TextButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Clear All Skills?'),
                          content: const Text(
                            'Are you sure you want to remove all skills?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() => _skills.clear());
                                _markChanged();
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error,
                              ),
                              child: const Text('Clear All'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.clear_all, size: 16),
                    label: const Text('Clear All'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingSmall),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _skills.map((skill) {
                return Chip(
                  avatar: CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.2),
                    child: const Icon(
                      Icons.check,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ),
                  label: Text(skill),
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  labelStyle: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () => _removeSkill(skill),
                  side: BorderSide(
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(AuthProvider authProvider) {
    return Column(
      children: [
        CustomButton(
          text: 'Save Changes',
          onPressed: _saveProfile,
          isLoading: authProvider.isLoading,
          icon: Icons.save,
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        OutlinedButton.icon(
          onPressed: authProvider.isLoading
              ? null
              : () async {
                  final shouldDiscard = await _onWillPop();
                  if (shouldDiscard && mounted) {
                    context.pop();
                  }
                },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            side: BorderSide(color: Colors.grey[400]!),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
            ),
          ),
          icon: const Icon(Icons.cancel_outlined),
          label: const Text('Cancel'),
        ),
      ],
    );
  }
} // <-- The missing closing brace for the class
