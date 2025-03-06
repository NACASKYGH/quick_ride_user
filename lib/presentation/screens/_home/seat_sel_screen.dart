import 'package:gap/gap.dart';
import '../../widget/app_button.dart';
import '../../../utils/constants.dart';
import 'package:flutter/material.dart';
import '../../widget/base_screen.dart';
import '../../widget/page_loader.dart';
import '../../widget/seat_widget.dart';
import '../../widget/image_loader.dart';
import '../../../utils/app_colors.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../../notifiers/buses_notifier.dart';
import '../../../entity/bus_info_entity.dart';
import 'package:quick_ride_user/utils/extensions.dart';
import 'package:easy_localization/easy_localization.dart';

class SeatSelScreen extends StatefulWidget {
  const SeatSelScreen({
    super.key,
    required this.bus,
  });

  final BusInfoEntity bus;

  @override
  State<SeatSelScreen> createState() => _SeatSelScreenState();
}

class _SeatSelScreenState extends State<SeatSelScreen> {
  late BusesNotifier busesNotifier;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      busesNotifier.activeBusNumber = widget.bus.busNo ?? '';
      await busesNotifier.getBusSeats(bus: widget.bus);
    });
  }

  @override
  Widget build(BuildContext context) {
    busesNotifier = context.watch<BusesNotifier>();

    /// Convert Date
    final DateFormat formatter = DateFormat('h:mma');
    final DateTime targetTime =
        formatter.tryParse(widget.bus.departTime ?? '') ?? DateTime.now();

    final DateFormat dateFormatter = DateFormat('dd-MMM-yyyy');
    final DateTime targetDate =
        dateFormatter.parse(busesNotifier.chosenDateTime);

    final DateTime now = DateTime.now();
    bool isTimePast = now.isAfter(targetDate) &&
        (now.hour > targetTime.hour ||
            (now.hour == targetTime.hour && now.minute > targetTime.minute));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: Text(
          'Select your seat(s)',
          style: context.textTheme.headlineSmall,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // CircularIconBtn(
          //   onTap: () async => await busesNotifier.getBusSeats(bus: widget.bus),
          //   icon: const Icon(
          //     Icons.refresh,
          //     size: 18,
          //   ),
          // ),
          // const Gap(10),
        ],
      ),
      body: BaseScreen(
        safeArea: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 34),
            child: Column(
              children: [
                Row(
                  children: [
                    ImageLoader(
                      imageUrl: widget.bus.avatar ?? emptyAssetImage,
                      isAsset: widget.bus.avatar == null,
                      width: 80,
                      height: 30,
                      fit: BoxFit.contain,
                    ),
                    const Gap(6),
                    Expanded(
                      child: Text(
                        '${widget.bus.fromLocation} -> ${widget.bus.toLocation}',
                        style: context.textTheme.headlineSmall?.copyWith(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: context.isDarkMode
                          ? AppColors.grey800
                          : AppColors.lightBg,
                      boxShadow: [
                        BoxShadow(
                          spreadRadius: 0,
                          blurRadius: 20,
                          color: context.isDarkMode
                              ? AppColors.grey800.withValues(alpha: .6)
                              : AppColors.divider,
                        ),
                      ],
                    ),
                    child: busesNotifier.isLoadingSeats
                        ? const PageLoader(
                            title: 'Arranging available seats...',
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 10),
                            itemCount: busesNotifier.busSeats.length ~/ 7,
                            itemBuilder: (context, index) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  for (int j = (index * 7);
                                      j < (index * 7) + 7;
                                      j++)
                                    SeatWidget(
                                      seatEntity: busesNotifier.busSeats[j],
                                    ),
                                ],
                              );
                            },
                          ),
                  ),
                ),
                const Gap(16),
                Container(
                  height: 76,
                  width: context.width,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      isTimePast
                          ? Container(
                              width: context.width,
                              padding: const EdgeInsets.all(6),
                              margin: const EdgeInsets.only(bottom: 5),
                              decoration: BoxDecoration(
                                color: AppColors.red,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                'Increase departure time to book a seat',
                                textAlign: TextAlign.center,
                                style: context.textTheme.labelSmall?.copyWith(
                                  color: AppColors.whiteText,
                                ),
                              ),
                            )
                          : Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    ...busesNotifier.selectedSeats.map((e) {
                                      return Container(
                                        alignment: Alignment.center,
                                        height: 24,
                                        width: 24,
                                        margin: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.primary,
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.darkBg
                                                  .withValues(alpha: .3),
                                              blurRadius: 5,
                                              spreadRadius: 0,
                                            )
                                          ],
                                        ),
                                        child: Text(
                                          (e.position ?? '')
                                              .replaceFirst('E', ''),
                                          textAlign: TextAlign.center,
                                          style: context.textTheme.labelSmall
                                              ?.copyWith(
                                            color: AppColors.whiteText,
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "GHS ${busesNotifier.selectedSeats.length * num.parse(widget.bus.lorryFare ?? '0')}",
                              style: context.textTheme.headlineSmall?.copyWith(
                                color: AppColors.whiteText,
                              ),
                            ),
                          ),
                          AppButton(
                            title: 'Next',
                            isDisabled: isTimePast ||
                                busesNotifier.selectedSeats.isEmpty,
                            width: 90,
                            height: 26,
                            radius: 5,
                            // bgColor: AppColors.whiteText,
                            // textColor: AppColors.primary,
                            onTap: () {},
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const Gap(12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
