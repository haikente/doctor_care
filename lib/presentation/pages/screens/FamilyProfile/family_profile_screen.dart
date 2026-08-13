import 'package:doctor_care/core/localization/app_localizations.dart';
import 'package:doctor_care/core/pages/custom_appbar.dart';
import 'package:doctor_care/domain/entities/family_profile.dart';
import 'package:doctor_care/presentation/bloc/family_profile/family_profile_cubit.dart';
import 'package:doctor_care/presentation/pages/screens/FamilyProfile/add_edit_family_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class FamilyProfileScreen extends StatelessWidget {
  const FamilyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: CustomStackAppBar(
        onBack: () => Navigator.pop(context),
        title: context.tr('manage_family_profiles'),
        centerTitle: true,
        icon: const Icon(
          Icons.add_circle_outline_outlined,
          color: Colors.white,
          size: 20,
        ),
        onInfo: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditFamilyProfileScreen(),
            ),
          );
        },
      ),
      body: BlocBuilder<FamilyProfileCubit, FamilyProfileState>(
        builder: (context, state) {
          if (state is FamilyProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is FamilyProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red.shade300,
                  ),
                  const Gap(12),
                  Text(
                    state.message,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const Gap(12),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<FamilyProfileCubit>().loadProfiles(),
                    child: Text(context.tr('retry')),
                  ),
                ],
              ),
            );
          }

          if (state is FamilyProfileLoaded) {
            if (state.profiles.isEmpty) {
              return _buildEmptyState(context);
            }
            return _buildProfileList(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.family_restroom,
              size: 64,
              color: Colors.blue.shade300,
            ),
          ),
          const Gap(24),
          Text(
            context.tr('no_family_profiles'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Gap(8),
          Text(
            context.tr('family_profile_empty_hint'),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const Gap(24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddEditFamilyProfileScreen(),
                ),
              );
            },
            icon: const Icon(Icons.person_add),
            label: Text(context.tr('add_profile')),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileList(BuildContext context, FamilyProfileLoaded state) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      itemCount: state.profiles.length,
      itemBuilder: (context, index) {
        final profile = state.profiles[index];
        final isActive = state.activeProfile?.id == profile.id;
        return _buildProfileCard(context, profile, isActive);
      },
    );
  }

  Widget _buildProfileCard(
    BuildContext context,
    FamilyProfile profile,
    bool isActive,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isActive
            ? Border.all(color: Colors.blue, width: 2)
            : Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: isActive
                ? Colors.blue.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddEditFamilyProfileScreen(profile: profile),
              ),
            );
          },
          onLongPress: () {
            if (!isActive) {
              context.read<FamilyProfileCubit>().switchProfile(profile.id!);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: profile.relationshipColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      profile.initials,
                      style: TextStyle(
                        color: profile.relationshipColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const Gap(14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              profile.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                context.tr('selected'),
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const Gap(4),
                      Row(
                        children: [
                          Icon(
                            profile.relationshipIcon,
                            size: 14,
                            color: Colors.grey.shade500,
                          ),
                          const Gap(4),
                          Text(
                            _relationshipLabel(context, profile.relationship),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          if (profile.age != null) ...[
                            const Gap(12),
                            Icon(
                              Icons.cake_outlined,
                              size: 14,
                              color: Colors.grey.shade500,
                            ),
                            const Gap(4),
                            Text(
                              context.tr(
                                'years_old_count',
                                params: {'count': '${profile.age}'},
                              ),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                          if (profile.gender != null) ...[
                            const Gap(12),
                            Text(
                              _genderLabel(context, profile.gender),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _relationshipLabel(BuildContext context, String relationship) {
    switch (relationship) {
      case 'self':
        return context.tr('rel_self');
      case 'spouse':
        return context.tr('rel_spouse');
      case 'child':
        return context.tr('rel_child');
      case 'parent':
        return context.tr('rel_parent');
      case 'sibling':
        return context.tr('rel_sibling');
      case 'grandparent':
        return context.tr('rel_grandparent');
      case 'other':
        return context.tr('rel_other');
      default:
        return context.tr('not_selected');
    }
  }

  String _genderLabel(BuildContext context, String? gender) {
    switch (gender) {
      case 'male':
        return context.tr('gender_male');
      case 'female':
        return context.tr('gender_female');
      case 'other':
        return context.tr('gender_other');
      default:
        return context.tr('not_selected');
    }
  }
}
