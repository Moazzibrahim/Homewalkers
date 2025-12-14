// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/presentation/viewModels/Marketer/leads/cubit/edit_lead/edit_lead_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/campaigns/get/cubit/get_campaigns_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/channels/channels_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/channels/channels_state.dart';
import 'package:homewalkers_app/presentation/viewModels/communication_ways/cubit/get_communication_ways_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/projects/projects_cubit.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/stages/stages_cubit.dart';

class EditLeadDialog extends StatefulWidget {
  final String userId;
  final String? initialName;
  final String? initialEmail;
  final String? initialPhone;
  final String? initialPhone2;
  final String? initialWhatsappNumber;
  final String? initialNotes;
  final String? initialProjectId;
  final String? initialStageId;
  final String? initialStalesId;
  final String? initialChannelId;
  final String? initialCampaignId;
  final String? initialCommunicationWayId;
  final bool? isCold;
  final void Function()? onSuccess;

  const EditLeadDialog({
    super.key,
    required this.userId,
    this.initialName,
    this.initialEmail,
    this.initialPhone,
    this.initialPhone2,
    this.initialWhatsappNumber,
    this.initialNotes,
    this.initialProjectId,
    this.initialStageId,
    this.initialStalesId,
    this.initialChannelId,
    this.initialCampaignId,
    this.initialCommunicationWayId,
    this.isCold,
    this.onSuccess,
  });

  @override
  State<EditLeadDialog> createState() => _EditLeadDialogState();
}

class _EditLeadDialogState extends State<EditLeadDialog> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController phone2Controller;
  late TextEditingController whatsappNumberController;
  late TextEditingController notesController;
  String? selectedProjectId;
  String? selectedStageId;
  String? selectedChannelId;
  String? selectedCampaignId;
  String? selectedStalesId;
  String? selectedCommunicationWayId;
  bool isCold = true;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.initialName ?? '');
    emailController = TextEditingController(text: widget.initialEmail ?? '');
    phoneController = TextEditingController(text: widget.initialPhone ?? '');
    phone2Controller = TextEditingController(text: widget.initialPhone2 ?? '');
    whatsappNumberController = TextEditingController(
      text: widget.initialWhatsappNumber ?? '',
    );
    notesController = TextEditingController(text: widget.initialNotes ?? '');
    selectedProjectId = widget.initialProjectId;
    selectedStageId = widget.initialStageId;
    selectedChannelId = widget.initialChannelId;
    selectedStalesId = widget.initialStalesId;
    selectedCampaignId = widget.initialCampaignId;
    selectedCommunicationWayId = widget.initialCommunicationWayId;
    isCold = widget.isCold ?? true;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    phone2Controller.dispose();
    whatsappNumberController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Lead'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
            ),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: 2,
            ),
            BlocBuilder<ProjectsCubit, ProjectsState>(
              builder: (context, state) {
                if (state is ProjectsSuccess) {
                  return SizedBox(
                    width: double.infinity,
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: selectedProjectId,
                      decoration: const InputDecoration(labelText: 'Project'),
                      items:
                          state.projectsModel.data!.map((project) {
                            return DropdownMenuItem<String>(
                              value: project.id.toString(),
                              child: Text(
                                project.name!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedProjectId = value;
                        });
                      },
                    ),
                  );
                } else if (state is ProjectsLoading) {
                  return const CircularProgressIndicator();
                }
                return const SizedBox();
              },
            ),
            BlocBuilder<StagesCubit, StagesState>(
              builder: (context, state) {
                if (state is StagesLoaded) {
                  return DropdownButtonFormField<String>(
                    value: selectedStageId,
                    decoration: const InputDecoration(labelText: 'Stage'),
                    items:
                        state.stages.map((stage) {
                          return DropdownMenuItem<String>(
                            value: stage.id.toString(),
                            child: Text(stage.name!),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedStageId = value;
                      });
                    },
                  );
                } else if (state is StagesLoading) {
                  return const CircularProgressIndicator();
                }
                return const SizedBox();
              },
            ),
            BlocBuilder<ChannelCubit, ChannelState>(
              builder: (context, state) {
                if (state is ChannelLoaded) {
                  return DropdownButtonFormField<String>(
                    value: selectedChannelId,
                    decoration: const InputDecoration(labelText: 'Channel'),
                    items:
                        state.channelResponse.data.map((channel) {
                          return DropdownMenuItem<String>(
                            value: channel.id.toString(),
                            child: Text(channel.name),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedChannelId = value;
                      });
                    },
                  );
                } else if (state is ChannelLoading) {
                  return const CircularProgressIndicator();
                }
                return const SizedBox();
              },
            ),
            BlocBuilder<GetCampaignsCubit, GetCampaignsState>(
              builder: (context, state) {
                if (state is GetCampaignsSuccess) {
                  return DropdownButtonFormField<String>(
                    value: selectedCampaignId,
                    decoration: const InputDecoration(labelText: 'Campaign'),
                    items:
                        state.campaigns.data!.map((campaign) {
                          return DropdownMenuItem<String>(
                            value: campaign.id.toString(),
                            child: SizedBox(
                              width: 200.w,
                              child: Text(
                                campaign.campainName!,
                                style: TextStyle(fontSize: 12.sp),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCampaignId = value;
                      });
                    },
                  );
                } else if (state is GetCampaignsLoading) {
                  return const CircularProgressIndicator();
                }
                return const SizedBox();
              },
            ),
            BlocBuilder<GetCommunicationWaysCubit, GetCommunicationWaysState>(
              builder: (context, state) {
                if (state is GetCommunicationWaysLoaded) {
                  return DropdownButtonFormField<String>(
                    value: selectedCommunicationWayId,
                    decoration: const InputDecoration(
                      labelText: 'Communication Way',
                    ),
                    items:
                        state.response.data!.map((way) {
                          return DropdownMenuItem<String>(
                            value: way.id.toString(),
                            child: Text(way.name!),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCommunicationWayId = value;
                      });
                    },
                  );
                } else if (state is GetCommunicationWaysLoading) {
                  return const CircularProgressIndicator();
                }
                return const SizedBox();
              },
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Leed Type",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Row(
                  children: [
                    Text(isCold ? "Cold" : "Fresh"),
                    Switch(
                      activeColor:
                          Theme.of(context).brightness == Brightness.light
                              ? Constants.maincolor
                              : Constants.mainDarkmodecolor,
                      value: isCold,
                      onChanged: (value) {
                        setState(() {
                          isCold = value;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        BlocConsumer<EditLeadCubit, EditLeadState>(
          listener: (context, state) {
            if (state is EditLeadSuccess) {
              Navigator.pop(context);
              if (widget.onSuccess != null) {
                widget.onSuccess!(); // 👈 Call callback
              }
              // ✅ بعد ما يحصل التعديل، نعمل تحديث مباشر للداتا

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edited Successfully')),
              );
            } else if (state is EditLeadFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Edit Failed: ${state.error}')),
              );
            }
          },
          builder: (context, state) {
            if (state is EditLeadLoading) {
              return const CircularProgressIndicator();
            }

            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Constants.maincolor,
              ),
              onPressed: () {
                // نجهز خريطة بالحقول اللي فيها قيم فعلًا
                final Map<String, dynamic> updatedFields = {};

                if (nameController.text.trim().isNotEmpty) {
                  updatedFields['name'] = nameController.text.trim();
                }
                if (emailController.text.trim().isNotEmpty) {
                  updatedFields['email'] = emailController.text.trim();
                }
                if (phoneController.text.trim().isNotEmpty) {
                  updatedFields['phone'] = phoneController.text.trim();
                }
                if (notesController.text.trim().isNotEmpty) {
                  updatedFields['notes'] = notesController.text.trim();
                }
                if (selectedProjectId != null &&
                    selectedProjectId!.isNotEmpty) {
                  updatedFields['project'] = selectedProjectId;
                }
                if (selectedStageId != null && selectedStageId!.isNotEmpty) {
                  updatedFields['stage'] = selectedStageId;
                }
                if (selectedChannelId != null &&
                    selectedChannelId!.isNotEmpty) {
                  updatedFields['chanel'] = selectedChannelId;
                }
                if (selectedCommunicationWayId != null &&
                    selectedCommunicationWayId!.isNotEmpty) {
                  updatedFields['communicationway'] =
                      selectedCommunicationWayId;
                }
                if (selectedCampaignId != null &&
                    selectedCampaignId!.isNotEmpty) {
                  updatedFields['campaign'] = selectedCampaignId;
                }

                updatedFields['leedtype'] = isCold ? "Cold" : "Fresh";

                // نتحقق إن فيه حاجة فعلاً اتغيرت
                if (updatedFields.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No changes to update')),
                  );
                  return;
                }

                // نرسل الداتا الفعلية
                context.read<EditLeadCubit>().editLead(
                  userId: widget.userId,
                  salesIdd: widget.initialStalesId,
                  name: updatedFields['name'],
                  email: updatedFields['email'],
                  phone: updatedFields['phone'],
                  notes: updatedFields['notes'],
                  project: updatedFields['project'],
                  stage: updatedFields['stage'],
                  chanel: updatedFields['chanel'],
                  communicationway: updatedFields['communicationway'],
                  leedtype: updatedFields['leedtype'],
                  campaign: updatedFields['campaign'],
                );
              },
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            );
          },
        ),
      ],
    );
  }
}
