import 'dart:collection';
import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:kraken/bridge.dart';

final String PERF_CONTROLLER_INIT_START = 'controller_init_start';
final String PERF_CONTROLLER_INIT_END = 'controller_init_end';
final String PERF_CONTROLLER_PROPERTY_INIT = 'controller_properties_init';
final String PERF_VIEW_CONTROLLER_INIT_START = 'view_controller_init_start';
final String PERF_VIEW_CONTROLLER_INIT_END = 'view_controller_init_end';
final String PERF_VIEW_CONTROLLER_PROPERTY_INIT = 'view_controller_property_init';
final String PERF_BRIDGE_INIT_START = 'bridge_init_start';
final String PERF_BRIDGE_INIT_END = 'bridge_init_end';
final String PERF_BRIDGE_REGISTER_DART_METHOD_START = 'bridge_register_dart_method_start';
final String PERF_BRIDGE_REGISTER_DART_METHOD_END = 'bridge_register_dart_method_end';
final String PERF_CREATE_VIEWPORT_START = 'create_viewport_start';
final String PERF_CREATE_VIEWPORT_END = 'create_viewport_end';
final String PERF_ELEMENT_MANAGER_INIT_START = 'element_manager_init_start';
final String PERF_ELEMENT_MANAGER_INIT_END = 'element_manager_init_end';
final String PERF_ELEMENT_MANAGER_PROPERTY_INIT = 'element_manager_property_init';
final String PERF_BODY_ELEMENT_INIT_START = 'body_element_init_start';
final String PERF_BODY_ELEMENT_INIT_END = 'body_element_init_end';
final String PERF_BODY_ELEMENT_PROPERTY_INIT = 'body_element_property_init';
final String PERF_JS_BUNDLE_LOAD_START = 'js_bundle_load_start';
final String PERF_JS_BUNDLE_LOAD_END = 'js_bundle_load_end';
final String PERF_JS_BUNDLE_EVAL_START = 'js_bundle_eval_start';
final String PERF_JS_BUNDLE_EVAL_END = 'js_bundle_eval_end';
final String PERF_FLUSH_UI_COMMAND_START = 'flush_ui_command_start';
final String PERF_FLUSH_UI_COMMAND_END = 'flush_ui_command_end';
final String PERF_CREATE_ELEMENT_START = 'create_element_start';
final String PERF_CREATE_ELEMENT_END = 'create_element_end';
final String PERF_CREATE_TEXT_NODE_START = 'create_text_node_start';
final String PERF_CREATE_TEXT_NODE_END = 'create_text_node_end';
final String PERF_CREATE_COMMENT_START = 'create_comment_start';
final String PERF_CREATE_COMMENT_END = 'create_comment_end';
final String PERF_DISPOSE_EVENT_TARGET_START = 'dispose_event_target_start';
final String PERF_DISPOSE_EVENT_TARGET_END = 'dispose_event_target_end';
final String PERF_ADD_EVENT_START = 'add_event_start';
final String PERF_ADD_EVENT_END = 'add_event_end';
final String PERF_INSERT_ADJACENT_NODE_START = 'insert_adjacent_node_start';
final String PERF_INSERT_ADJACENT_NODE_END = 'insert_adjacent_node_end';
final String PERF_REMOVE_NODE_START = 'remove_node_start';
final String PERF_REMOVE_NODE_END = 'remove_node_end';
final String PERF_SET_STYLE_START = 'set_style_start';
final String PERF_SET_STYLE_END = 'set_style_end';
final String PERF_SET_PROPERTIES_START = 'set_properties_start';
final String PERF_SET_PROPERTIES_END = 'set_properties_end';
final String PERF_REMOVE_PROPERTIES_START = 'remove_properties_start';
final String PERF_REMOVE_PROPERTIES_END = 'remove_properties_end';
final String PERF_FLEX_LAYOUT_START = 'flex_layout_start';
final String PERF_FLEX_LAYOUT_END = 'flex_layout_end';
final String PERF_FLOW_LAYOUT_START = 'flow_layout_start';
final String PERF_FLOW_LAYOUT_END = 'flow_layout_end';
final String PERF_INTRINSIC_LAYOUT_START = 'intrinsic_layout_start';
final String PERF_INTRINSIC_LAYOUT_END = 'intrinsic_layout_end';
final String PERF_SILVER_LAYOUT_START = 'silver_layout_start';
final String PERF_SILVER_LAYOUT_END = 'silver_layout_end';
final String PERF_PAINT_START = 'paint_start';
final String PERF_PAINT_END = 'paint_end';

class PerformanceEntry {
  PerformanceEntry(this.name, this.startTime, this.uniqueId);

  final String name;
  final int startTime;
  final int uniqueId;
}

final int PERFORMANCE_NONE_UNIQUE_ID = -1024;

class PerformanceTiming {
  static SplayTreeMap<int, PerformanceTiming> _instanceMap = SplayTreeMap();

  static PerformanceTiming instance(int contextId) {
    if (!_instanceMap.containsKey(contextId)) {
      _instanceMap[contextId] = PerformanceTiming();
    }
    return _instanceMap[contextId];
  }

  int entriesSize = 0;

  void mark(String name, {int startTime, int uniqueId}) {
    if (startTime == null) {
      startTime = DateTime.now().microsecondsSinceEpoch;
    }

    if (uniqueId == null) {
      uniqueId = PERFORMANCE_NONE_UNIQUE_ID;
    }

    PerformanceEntry entry = PerformanceEntry(name, startTime, uniqueId);
    entries[entriesSize++] = entry;
  }

  Pointer<NativePerformanceEntryList> toNative() {
    Pointer<NativePerformanceEntryList> list = allocate<NativePerformanceEntryList>();
    int byteLength = entriesSize * 3;

    Uint64List data = Uint64List(byteLength);

    int dataIndex = 0;

    for (int i = 0; i < byteLength; i += 3) {
      data[i] = Utf8.toUtf8(entries[dataIndex].name).address;
      data[i + 1] = entries[dataIndex].startTime;
      data[i + 2] = entries[dataIndex].uniqueId;
      dataIndex++;
    }

    final Pointer<Uint64> bytes = allocate<Uint64>(count: byteLength);
    final Uint64List buffer = bytes.asTypedList(byteLength);
    buffer.setAll(0, data);

    list.ref.length = entriesSize;
    list.ref.entries = bytes;

    return list;
  }

  // Pre allocate big list for better performance.
  List<PerformanceEntry> entries = List.filled(1000000, null, growable: true);
}
