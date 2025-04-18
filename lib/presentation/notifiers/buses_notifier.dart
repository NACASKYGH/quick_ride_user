import '/di.dart';
import '/utils/extensions.dart';
import '/repository/repository.dart';
import 'package:flutter/material.dart';
import '../../entity/bus_info_entity.dart';
import '../../entity/bus_seat_entity.dart';

class BusesNotifier extends ChangeNotifier {
  Repository get _repository => getIt<Repository>();

  String _chosenDateTime = DateTime.now().dateMMMonthYear;
  String get chosenDateTime => _chosenDateTime;
  set chosenDateTime(String value) {
    _chosenDateTime = value;
    notifyListeners();
  }

  List<String> _locations = [];
  List<String> get locations => _locations;

  Future<void> getLocations() async {
    if (_locations.isNotEmpty) return;
    try {
      final resp = await _repository.getLocations();
      _locations =
          resp.map((item) => item.splitReturnMerge(' ', [0])).toSet().toList();

      notifyListeners();
    } catch (e) {
      logger.d(e);
      _locations = [];
      notifyListeners();
    }
  }

  List<BusInfoEntity> _busesInfo = [];
  List<BusInfoEntity> get busesInfo => _busesInfo;

  bool isLoading = false;

  String? _getBusesErrorMsg;
  String? get getBusesErrorMsg => _getBusesErrorMsg;

  Future<void> getBuses({required String from, required String to}) async {
    if (isLoading) return;

    isLoading = true;
    _getBusesErrorMsg = null;
    notifyListeners();

    try {
      final resp = await _repository.searchTravelResult(
        from: from,
        to: to,
        date: _chosenDateTime,
      );
      busesInfo.clear();
      _busesInfo = [];
      _busesInfo = resp;
      isLoading = false;
      _getBusesErrorMsg = null;
      notifyListeners();
    } catch (e) {
      _getBusesErrorMsg = e.toString();
      busesInfo.clear();
      _busesInfo = [];
      isLoading = false;
      notifyListeners();
    }
  }

  List<BusSeatEntity> _busSeats = [];
  List<BusSeatEntity> get busSeats => _busSeats;
  bool isLoadingSeats = false;

  Future<String?> getBusSeats({required BusInfoEntity bus}) async {
    if (isLoadingSeats) return null;
    isLoadingSeats = true;
    _busSeats = [];
    notifyListeners();

    try {
      final resp = await _repository.getBusSeats(
        toId: bus.destinationId ?? '',
        fromId: bus.fromLocationId ?? '',
        tripId: num.parse(bus.tripId ?? ''),
        travelDate: chosenDateTime,
      );

      _busSeats = resp;
      isLoadingSeats = false;
      notifyListeners();
      return null;
    } catch (e) {
      isLoadingSeats = false;
      notifyListeners();
      logger.e(e);
      return e.toString();
    }
  }

  String _activeBusNumber = '';
  String get activeBusNumber => _activeBusNumber;
  set activeBusNumber(String value) {
    _activeBusNumber = value;
    notifyListeners();
  }

  List<BusSeatEntity> _selectedSeats = [];
  List<BusSeatEntity> get selectedSeats => _selectedSeats;
  set removeSeat(BusSeatEntity value) {
    _selectedSeats =
        _selectedSeats.where((seat) => seat.id != value.id).toList();
    notifyListeners();
  }

  set selectSeat(BusSeatEntity value) {
    _selectedSeats.add(value);
    notifyListeners();
  }

  void clearBusSeats() {
    _busSeats = [];
    notifyListeners();
  }

  void clearSelectedSeats() {
    _selectedSeats = [];
    notifyListeners();
  }

  void clearAvailableBusses() {
    _busesInfo = [];
    notifyListeners();
  }

  Future<String?> getNameFromPhone({required String phone}) async {
    try {
      final resp = await _repository.getNameFromPhone(phone: phone);
      return resp;
    } catch (e) {
      return null;
    }
  }
}
