import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gm;

class GoogleMapLayerPlugin extends MapPlugin {
  @override
  Widget createLayer(
    LayerOptions options,
    MapState state,
    Stream<Null> stream,
  ) {
    return GoogleMapLayer(
      options: options as GoogleMapLayerOptions,
      state: state,
      stream: stream,
    );
  }

  @override
  bool supportsLayer(LayerOptions options) {
    return options is GoogleMapLayerOptions;
  }
}

class GoogleMapLayerOptions extends LayerOptions {}

class GoogleMapLayer extends StatefulWidget {
  final GoogleMapLayerOptions options;
  final Stream<Null> stream;
  final MapState state;

  const GoogleMapLayer({
    Key? key,
    required this.options,
    required this.state,
    required this.stream,
  }) : super(key: key);

  @override
  State<GoogleMapLayer> createState() => _GoogleMapLayerState();
}

class _GoogleMapLayerState extends State<GoogleMapLayer> {
  MapState get state => widget.state;

  late gm.GoogleMapController _controller;

  gm.LatLng get center {
    final c = state.center;
    return gm.LatLng(c.latitude, c.longitude);
  }

  @override
  void initState() {
    super.initState();
    widget.stream.listen((event) {
      _controller.moveCamera(
        gm.CameraUpdate.newLatLngZoom(center, state.zoom),
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return gm.GoogleMap(
      mapType: gm.MapType.normal,
      initialCameraPosition: gm.CameraPosition(
        target: center,
        zoom: state.zoom,
      ),
      rotateGesturesEnabled: false,
      zoomGesturesEnabled: true,
      tiltGesturesEnabled: false,
      scrollGesturesEnabled: true,
      zoomControlsEnabled: true,
      myLocationEnabled: false,
      onMapCreated: (controller) {
        _controller = controller;
      },
    );
  }
}
