import 'package:cached_network_image/cached_network_image.dart';
import 'package:codepan/resources/dimensions.dart';
import 'package:codepan/utils/debouncer.dart';
import 'package:codepan/utils/stored_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as lt;

const _folder = 'MapTiles';

abstract class MapState<T extends StatefulWidget> extends State<T>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late MapController _mapController;
  late _CenterZoomTween _tween;
  late Debouncer _debouncer;

  List<lt.LatLng> get coordinates;

  @protected
  MapController get mapController => _mapController;

  Debouncer get tileDebouncer => _debouncer;

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
    _debouncer = Debouncer();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @protected
  void recenterCamera({
    FitBoundsOptions? options,
  }) {
    final d = Dimension.of(context);
    final cz = mapController.centerZoomFitBounds(
      bounds,
      options: options ??
          FitBoundsOptions(
            padding: EdgeInsets.all(d.at(20)),
          ),
    );
    animateCamera(cz);
  }

  @protected
  void animateCamera(CenterZoom cz) {
    _tween = _CenterZoomTween(
      begin: CenterZoom(
        center: _mapController.center,
        zoom: _mapController.zoom,
      ),
      end: cz,
    );
    _animController.value = 0;
    _animController.forward();
  }
}

class _CenterZoomTween extends Tween<CenterZoom> {
  _CenterZoomTween({
    required CenterZoom begin,
    required CenterZoom end,
  }) : super(
          begin: begin,
          end: end,
        );

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
  const CachedTileProvider();

  @override
  ImageProvider<Object> getImage(
    Coords<num> coords,
    TileLayerOptions options,
  ) {
    final url = getTileUrl(coords, options);
    return CachedNetworkImageProvider(url);
  }
}

class StoredNetworkImageTileProvider extends TileProvider {
  final Debouncer debouncer;

  StoredNetworkImageTileProvider(this.debouncer);

  @override
  ImageProvider<Object> getImage(
    Coords<num> coords,
    TileLayerOptions options,
  ) {
    return StoredNetworkImage(
      getTileUrl(coords, options),
      folder: _folder,
      fileLimit: 1000,
      debouncer: debouncer,
    );
  }
}
