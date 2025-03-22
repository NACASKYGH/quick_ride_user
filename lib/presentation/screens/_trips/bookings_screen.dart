import 'package:gap/gap.dart';
import 'package:flutter/material.dart';
import '../../widget/base_screen.dart';
import '../../widget/page_loader.dart';
import '../../../utils/app_colors.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../../../entity/ticket_entity.dart';
import '../../widget/error_state_widget.dart';
import 'package:quick_ride_user/utils/extensions.dart';
import 'package:quick_ride_user/presentation/notifiers/trips_notifier.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  late TripsNotifier tripsNotifier;

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      tripsNotifier.getTicketBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    tripsNotifier = context.watch<TripsNotifier>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        // title: Text(
        //   'Available Buses',
        //   style: context.textTheme.headlineSmall,
        // ),
      ),
      body: BaseScreen(
        safeArea: SafeArea(
          child: Column(
            children: [
              const Gap(12),
              Expanded(
                child: (tripsNotifier.getBookingsErrorMsg ?? '').isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 70.0),
                        child: ErrorStateWidget(
                            title: 'Oops!',
                            desc: tripsNotifier.getBookingsErrorMsg ??
                                'An error occurred.',
                            onRetry: () {
                              tripsNotifier.getTicketBookings();
                            }),
                      )
                    : tripsNotifier.isLoading &&
                            tripsNotifier.bookingsList.isEmpty
                        ? const PageLoader(
                            title: 'Loading available buses...',
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(top: 8, bottom: 32),
                            itemCount: tripsNotifier.bookingsList.length,
                            itemBuilder: (context, index) {
                              return TicketItem(
                                ticketEntity: tripsNotifier.bookingsList[index],
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TicketItem extends StatelessWidget {
  const TicketItem({
    super.key,
    required this.ticketEntity,
  });

  final TicketEntity ticketEntity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, left: 16, right: 16),
      child: Material(
        color: context.isDarkMode ? AppColors.grey800 : AppColors.lightBg,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFF2F2F2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${ticketEntity.fromStation} -> ${ticketEntity.toStation}',
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontSize: 13,
                  ),
                ),
                Text(
                  '${ticketEntity.fromStation} -> ${ticketEntity.toStation}',
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontSize: 13,
                  ),
                ),
                const Gap(6),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            textAlign: TextAlign.start,
                            text: TextSpan(
                                text: 'Report Tim\n',
                                style: context.textTheme.labelSmall?.copyWith(
                                  fontSize: 9,
                                ),
                                children: [
                                  TextSpan(
                                    text:
                                        // reportingTime?.format(context) ??
                                        'N/A',
                                    style: context.textTheme.headlineSmall
                                        ?.copyWith(
                                      fontSize: 10,
                                    ),
                                  ),
                                ]),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            textAlign: TextAlign.start,
                            text: TextSpan(
                                text: 'Depart Time\n',
                                style: context.textTheme.labelSmall?.copyWith(
                                  fontSize: 9,
                                ),
                                children: [
                                  TextSpan(
                                    text:
                                        // departingTime?.format(context) ??
                                        'N/A',
                                    style: context.textTheme.headlineSmall
                                        ?.copyWith(
                                      fontSize: 10,
                                    ),
                                  ),
                                ]),
                          ),
                        ],
                      ),
                    ),

                    ///
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.lightBlue.withValues(alpha: .06),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Seat\nNumber',
                            style: context.textTheme.labelSmall?.copyWith(
                              fontSize: 8,
                              height: 0,
                              color: AppColors.lightBlue,
                            ),
                          ),
                          const Gap(5),
                          Text(
                            ticketEntity.seatNo ?? '',
                            style: context.textTheme.headlineSmall?.copyWith(
                              fontSize: 18,
                              color: AppColors.lightBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(4),

                    ///
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.lightBlue,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        'GHS\n${ticketEntity.fare}',
                        style: context.textTheme.headlineSmall?.copyWith(
                          fontSize: 12,
                          color: AppColors.whiteText,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
