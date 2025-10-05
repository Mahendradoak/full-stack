import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/job_provider.dart';
import '../utils/constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final jobProvider = Provider.of<JobProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await Future.wait([
                  jobProvider.fetchSavedJobs(),
                  Future.delayed(const Duration(milliseconds: 500)),
                ]);
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Custom App Bar with Gradient
                  _buildSliverAppBar(context, user),

                  // Body Content
                  SliverList(
                    delegate: SliverChildListDelegate([
                      Padding(
                        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            children: [
                              // Quick Actions
                              _buildQuickActions(context),
                              const SizedBox(height: AppDimensions.paddingLarge),

                              // Stats Section
                              _buildStatsSection(context, user, jobProvider),
                              const SizedBox(height: AppDimensions.paddingLarge),

                              // Account Details
                              _buildSectionHeader(context, 'Account Details'),
                              const SizedBox(height: AppDimensions.paddingSmall),
                              _buildAccountDetails(context, user),
                              const SizedBox(height: AppDimensions.paddingLarge),

                              // Bio Section
                              if (user.bio.isNotEmpty) ...[
                                _buildSectionHeader(context, 'About Me'),
                                const SizedBox(height: AppDimensions.paddingSmall),
                                _buildBioCard(context, user.bio),
                                const SizedBox(height: AppDimensions.paddingLarge),
                              ],

                              // Skills Section
                              _buildSectionHeader(context, 'Skills & Expertise'),
                              const SizedBox(height: AppDimensions.paddingSmall),
                              _buildSkillsCard(context, user),
                              const SizedBox(height: AppDimensions.paddingLarge),

                              // Resume Section
                              if (user.resumeLink.isNotEmpty) ...[
                                _buildSectionHeader(context, 'Resume'),
                                const SizedBox(height: AppDimensions.paddingSmall),
                                _buildResumeCard(context, user.resumeLink),
                                const SizedBox(height: AppDimensions.paddingLarge),
                              ],

                              // App Settings
                              _buildSectionHeader(context, 'App Settings'),
                              const SizedBox(height: AppDimensions.paddingSmall),
                              _buildSettingsCard(context, themeProvider),
                              const SizedBox(height: AppDimensions.paddingLarge),

                              // Logout Button
                              _buildLogoutButton(context, authProvider),
                              const SizedBox(height: AppDimensions.paddingXLarge),

                              // App Version
                              _buildAppVersion(context),
                              const SizedBox(height: AppDimensions.paddingLarge),
                            ],
                          ),
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, user) {
    return SliverAppBar(
      expandedHeight: 280,
      floating: false,
      pinned: true,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primary.withOpacity(0.8),
                AppColors.secondary.withOpacity(0.6),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Profile Picture with Badge
                Stack(
                  children: [
                    Hero(
                      tag: 'profile_avatar',
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            user.name[0].toUpperCase(),
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
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.paddingMedium),

                // Name
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),

                // Email Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.email_outlined,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        user.email,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: () => context.push('/edit-profile'),
          tooltip: 'Edit Profile',
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            context,
            icon: Icons.edit,
            label: 'Edit Profile',
            color: AppColors.primary,
            onTap: () => context.push('/edit-profile'),
          ),
        ),
        const SizedBox(width: AppDimensions.paddingSmall),
        Expanded(
          child: _buildActionButton(
            context,
            icon: Icons.share,
            label: 'Share',
            color: AppColors.info,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Share feature coming soon!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, user, JobProvider jobProvider) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.bookmark,
            count: '${jobProvider.savedJobs.length}',
            label: 'Saved Jobs',
            color: AppColors.secondary,
            onTap: () {
              DefaultTabController.of(context)?.animateTo(2);
            },
          ),
        ),
        const SizedBox(width: AppDimensions.paddingSmall),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.code,
            count: '${user.skills.length}',
            label: 'Skills',
            color: AppColors.info,
            onTap: () => context.push('/edit-profile'),
          ),
        ),
        const SizedBox(width: AppDimensions.paddingSmall),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.work,
            count: '${jobProvider.jobs.length}+',
            label: 'Available',
            color: AppColors.success,
            onTap: () {
              DefaultTabController.of(context)?.animateTo(1);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String count,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: AppDimensions.paddingSmall),
            Text(
              count,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
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
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildAccountDetails(BuildContext context, user) {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          _buildDetailTile(
            icon: Icons.person_outline,
            title: 'Full Name',
            value: user.name,
            color: AppColors.primary,
          ),
          const Divider(height: 1),
          _buildDetailTile(
            icon: Icons.email_outlined,
            title: 'Email Address',
            value: user.email,
            color: AppColors.info,
          ),
          const Divider(height: 1),
          _buildDetailTile(
            icon: Icons.admin_panel_settings_outlined,
            title: 'Account Type',
            value: user.role.toUpperCase(),
            color: AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTile({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildBioCard(BuildContext context, String bio) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.info_outline,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppDimensions.paddingMedium),
            Expanded(
              child: Text(
                bio,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsCard(BuildContext context, user) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: user.skills.isEmpty
            ? _buildEmptyState(
                icon: Icons.code_off,
                message: 'No skills added yet',
                actionLabel: 'Add Skills',
                onAction: () => context.push('/edit-profile'),
              )
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: user.skills.map((skill) {
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
                    side: BorderSide(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  );
                }).toList(),
              ),
      ),
    );
  }

  Widget _buildResumeCard(BuildContext context, String resumeLink) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.description,
            color: AppColors.secondary,
          ),
        ),
        title: const Text(
          'Resume Document',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          resumeLink,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.content_copy),
          color: AppColors.primary,
          onPressed: () {
            Clipboard.setData(ClipboardData(text: resumeLink));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Resume link copied to clipboard!'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          tooltip: 'Copy link',
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, ThemeProvider themeProvider) {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          SwitchListTile(
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: AppColors.warning,
              ),
            ),
            title: const Text(
              'Dark Mode',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              themeProvider.isDarkMode ? 'Enabled' : 'Disabled',
              style: TextStyle(color: Colors.grey[600]),
            ),
            value: themeProvider.isDarkMode,
            onChanged: (value) => themeProvider.toggleTheme(),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.notifications_outlined,
                color: AppColors.info,
              ),
            ),
            title: const Text(
              'Notifications',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              'Coming soon',
              style: TextStyle(color: Colors.grey[600]),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notifications feature coming soon!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.help_outline,
                color: AppColors.success,
              ),
            ),
            title: const Text(
              'Help & Support',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Help & Support coming soon!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider authProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _handleLogout(context, authProvider),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
          ),
        ),
        icon: const Icon(Icons.logout),
        label: const Text(
          'Logout',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAppVersion(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            '${AppStrings.appName} v1.0.0',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Made with ❤️ by Your Team',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          children: [
            Icon(icon, size: 48, color: Colors.grey[400]),
            const SizedBox(height: AppDimensions.paddingSmall),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppDimensions.paddingMedium),
              TextButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context, AuthProvider authProvider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.warning),
            SizedBox(width: 12),
            Text('Logout'),
          ],
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await authProvider.logout();
      if (context.mounted) {
        context.go('/login');
      }
    }
  }
}