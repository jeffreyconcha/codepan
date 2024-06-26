import 'package:cached_network_image/cached_network_image.dart';
import 'package:codepan/resources/dimensions.dart';
import 'package:codepan/utils/debouncer.dart';
import 'package:codepan/utils/stored_network_image.dart';
import 'package:codepan/widgets/states/permission_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as lt;

const _folder = 'MapTiles';
const _tileCacheLimit = 20000;

abstract class MapState<T extends StatefulWidget> extends PermissionState<T>
    with SingleTickerProviderStateMixin {
  late StoredNetworkImageTileProvider _tileProvider;
  late AnimationController _animController;
  late MapController _mapController;
  late _CenterZoomTween _tween;

  List<lt.LatLng> get coordinates;

  @protected
  MapController get mapController => _mapController;

  StoredNetworkImageTileProvider get tileProvider => _tileProvider;

  int get tileCacheLimit => _tileCacheLimit;

  @protected
  LatLngBounds get bounds {
    double neLat = 0;
    double neLng = 0;
    double swLat = 0;
    double swLng = 0;
    for (final point in coordinates) {
      if (point.latitude != 0 && point.longitude != 0) {
        if (point.latitude < neLat || neLat == 0) {
          neLat = point.latitude;
        }
        if (point.longitude < neLng || neLng == 0) {
          neLng = point.longitude;
        }
        if (point.latitude > swLat) {
          swLat = point.latitude;
        }
        if (point.longitude > swLng) {
          swLng = point.longitude;
        }
      }
    }
    return LatLngBounds(
      lt.LatLng(neLat, neLng),
      lt.LatLng(swLat, swLng),
    );
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
      final cz = _tween.lerp(animation.value);
      _mapController.move(cz.center, cz.zoom);
    });
    animation.addStatusListener((status) {
      switch (status) {
        case AnimationStatus.completed:
        case AnimationStatus.dismissed:
          break;
        default:
          break;
      }
    });
    _mapController = MapController();
    final debouncer = Debouncer(milliseconds: 250);
    _tileProvider = StoredNetworkImageTileProvider(
      debouncer: debouncer,
      tileCacheLimit: tileCacheLimit,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @protected
  void recenterCamera({
    EdgeInsets? padding,
  }) {
    final d = Dimension.of(context);
    final fit = CameraFit.bounds(
      bounds: bounds,
      padding: padding ?? EdgeInsets.all(d.at(20)),
    );
    final c = fit.fit(mapController.camera);
    animateCamera(
      CenterZoom(center: c.center, zoom: c.zoom),
    );
  }

  @protected
  void animateCamera(CenterZoom cz) {
    _tween = _CenterZoomTween(
      begin: CenterZoom(
        center: _mapController.camera.center,
        zoom: _mapController.camera.zoom,
      ),
      end: cz,
    );
    _animController.value = 0;
    _animController.forward();
  }
}

class _CenterZoomTween extends Tween<CenterZoom> {
  _CenterZoomTween({
    required super.begin,
    required super.end,
  });

  @override
  CenterZoom lerp(double value) {
    final cs = begin!.center;
    final ce = end!.center;
    return CenterZoom(
      center: lt.LatLng(
        _lerp(cs.latitude, ce.latitude, value),
        _lerp(cs.longitude, ce.longitude, value),
      ),
      zoom: _lerp(begin!.zoom, end!.zoom, value),
    );
  }

  double _lerp(
    double begin,
    double end,
    double value,
  ) {
    return begin + (end - begin) * value;
  }
}

class CachedTileProvider extends TileProvider {
  @override
  ImageProvider<Object> getImage(
    TileCoordinates coords,
    TileLayer options,
  ) {
    final url = getTileUrl(coords, options);
    return CachedNetworkImageProvider(url);
  }
}

class StoredNetworkImageTileProvider extends TileProvider {
  final Debouncer debouncer;
  final int tileCacheLimit;

  StoredNetworkImageTileProvider({
    required this.debouncer,
    required this.tileCacheLimit,
  });

  @override
  ImageProvider<Object> getImage(
    TileCoordinates coords,
    TileLayer options,
  ) {
    return StoredNetworkImage(
      getTileUrl(coords, options),
      folder: _folder,
      fileLimit: tileCacheLimit,
      debouncer: debouncer,
    );
  }
}
