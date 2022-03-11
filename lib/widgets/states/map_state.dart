import 'package:codepan/resources/dimensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as lt;

abstract class MapState<T extends StatefulWidget> extends State<T>
    with TickerProviderStateMixin {
  late AnimationController _animController;
  late MapController _mapController;
  Tween<double>? _latTween, _lngTween, _zoomTween;

  List<lt.LatLng> get coordinates;

  @protected
  MapController get mapController => _mapController;

  @protected
  LatLngBounds get bounds {
    final ne = lt.LatLng(0, 0);
    final sw = lt.LatLng(0, 0);
    for (final point in coordinates) {
      if (point.latitude != 0 && point.longitude != 0) {
        if (point.latitude < ne.latitude || ne.latitude == 0) {
          ne.latitude = point.latitude;
        }
        if (point.longitude < ne.longitude || ne.longitude == 0) {
          ne.longitude = point.longitude;
        }
        if (point.latitude > sw.latitude) {
          sw.latitude = point.latitude;
        }
        if (point.longitude > sw.longitude) {
          sw.longitude = point.longitude;
        }
      }
    }
    return LatLngBounds(ne, sw);
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    final animation = CurvedAnimation(
      parent: _animController,
      curve: Curves.fastOutSlowIn,
    );
    _animController.addListener(() {
      if (_latTween != null && _lngTween != null && _zoomTween != null) {
        _mapController.move(
          lt.LatLng(
            _latTween!.evaluate(animation),
            _lngTween!.evaluate(animation),
          ),
          _zoomTween!.evaluate(animation),
        );
      }
    });
    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {}
    });
    _animController.forward();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @protected
  void recenterCamera() {
    final d = Dimension.of(context);
    final point = mapController.centerZoomFitBounds(
      bounds,
      options: FitBoundsOptions(
        padding: EdgeInsets.all(d.at(20)),
      ),
    );
    animateCamera(point.center, point.zoom);
  }

  @protected
  void animateCamera(lt.LatLng center, double zoom) {
    _latTween = Tween<double>(
      begin: _mapController.center.latitude,
      end: center.latitude,
    );
    _lngTween = Tween<double>(
      begin: _mapController.center.longitude,
      end: center.longitude,
    );
    _zoomTween = Tween<double>(
      begin: _mapController.zoom,
      end: zoom,
    );
    _animController.forward();
  }
}
