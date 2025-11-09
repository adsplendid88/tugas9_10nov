class DeviceModel {
  final String id;
  final String name;
  final Map<String, dynamic>? data;

  DeviceModel({
    required this.id,
    required this.name,
    this.data,
  });

  // Factory constructor to create a DeviceModel from JSON
  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  // Method to convert DeviceModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'data': data,
    };
  }

  // Helper method to get formatted device details
  String getDetails() {
    if (data == null || data!.isEmpty) {
      return 'No additional details available';
    }

    List<String> details = [];
    data!.forEach((key, value) {
      details.add('$key: $value');
    });
    return details.join('\n');
  }

  // Helper method to get price if available
  String? getPrice() {
    if (data != null) {
      if (data!.containsKey('price')) {
        return '\$${data!['price']}';
      } else if (data!.containsKey('Price')) {
        return '\$${data!['Price']}';
      }
    }
    return null;
  }

  // Helper method to get color if available
  String? getColor() {
    if (data != null) {
      if (data!.containsKey('color')) {
        return data!['color'].toString();
      } else if (data!.containsKey('Color')) {
        return data!['Color'].toString();
      } else if (data!.containsKey('Strap Colour')) {
        return data!['Strap Colour'].toString();
      }
    }
    return null;
  }
}