import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/formatters.dart';
import '../models/internship_model.dart';

class InternshipCard extends StatelessWidget {
  final InternshipModel internship;
  final VoidCallback onTap;
  final VoidCallback? onBookmarkToggle;

  const InternshipCard({
    super.key,
    required this.internship,
    required this.onTap,
    this.onBookmarkToggle,
  });

  @override
  Widget build(BuildContext context) {
    final company = internship.company;
    final companyName = company?.companyName ?? 'Perusahaan';
    final logoUrl = company?.logoUrl;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppConstants.borderColor, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Company logo & name + Bookmark button
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppConstants.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: logoUrl != null && logoUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: logoUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, _) => const Icon(
                              Icons.business,
                              color: AppConstants.primaryColor,
                            ),
                            errorWidget: (_, _, _) => const Icon(
                              Icons.business,
                              color: AppConstants.primaryColor,
                            ),
                          )
                        : const Icon(
                            Icons.business,
                            color: AppConstants.primaryColor,
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          companyName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppConstants.secondaryColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          internship.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppConstants.textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onBookmarkToggle != null)
                    IconButton(
                      icon: Icon(
                        internship.isSaved
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_outline_rounded,
                        color: internship.isSaved
                            ? AppConstants.primaryColor
                            : const Color(0xFF94A3B8),
                        size: 24,
                      ),
                      onPressed: onBookmarkToggle,
                    ),
                ],
              ),
              const SizedBox(height: 14),

              // Badges row: Location, Work Type, Salary
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _InfoChip(
                    icon: Icons.location_on_outlined,
                    label: internship.location,
                  ),
                  _InfoChip(
                    icon: Icons.work_outline,
                    label: internship.workType,
                  ),
                  _InfoChip(
                    icon: Icons.access_time,
                    label: internship.duration,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Salary row & Requirements
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Formatters.formatSalaryRange(
                      internship.salaryMin,
                      internship.salaryMax,
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                  Text(
                    'Sisa kuota: ${internship.quota}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppConstants.secondaryColor,
                    ),
                  ),
                ],
              ),

              if (internship.requirements.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  children: internship.requirements.take(3).map((req) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        req,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF475569),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppConstants.borderColor, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppConstants.secondaryColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppConstants.textColor,
            ),
          ),
        ],
      ),
    );
  }
}
