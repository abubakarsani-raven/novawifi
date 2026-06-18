// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wifi_network.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WifiNetworkAdapter extends TypeAdapter<WifiNetwork> {
  @override
  final int typeId = 0;

  @override
  WifiNetwork read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WifiNetwork(
      id: fields[0] as String,
      ssid: fields[1] as String,
      password: fields[2] as String,
      label: fields[3] as String,
      writtenToTag: fields[4] as bool,
      updatedAt: fields[5] as DateTime?,
      tagLocked: fields[6] as bool,
      tagProvisioned: fields[7] as bool,
      isConfigured: fields[8] as bool,
      securityType: fields[9] as String? ?? 'WPA2',
      isHidden: fields[10] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, WifiNetwork obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.ssid)
      ..writeByte(2)
      ..write(obj.password)
      ..writeByte(3)
      ..write(obj.label)
      ..writeByte(4)
      ..write(obj.writtenToTag)
      ..writeByte(5)
      ..write(obj.updatedAt)
      ..writeByte(6)
      ..write(obj.tagLocked)
      ..writeByte(7)
      ..write(obj.tagProvisioned)
      ..writeByte(8)
      ..write(obj.isConfigured)
      ..writeByte(9)
      ..write(obj.securityType)
      ..writeByte(10)
      ..write(obj.isHidden);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WifiNetworkAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
