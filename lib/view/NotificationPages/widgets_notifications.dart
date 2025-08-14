import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:quotes_daily/Utils/colors/AppColors.dart';

Widget buildPermissionButton(
    BuildContext context, {
      required PermissionStatus status,
      required VoidCallback onRequest,
    }) {
  final isPermDenied = status.isPermanentlyDenied;
  return ElevatedButton(
    onPressed: isPermDenied ? openAppSettings : onRequest,
    child: Text(
      isPermDenied
          ? "Enable notifications in Settings"
          : "Enable notifications",
      style: TextStyle(color: AppColors.appColor)
    ),
  );
}

Widget buildTimePickerButton(
    BuildContext context, {
      required String label,
      required Time initialTime,
      required ValueChanged<Time> onTimeChanged,
    }) {
  return TextButton(
    style: TextButton.styleFrom(
      backgroundColor: AppColors.appColor,
      elevation: 5,
    ),
    onPressed: () {
      Navigator.of(context).push(
        showPicker(
          context: context,
          value: initialTime,
          sunrise: const TimeOfDay(hour: 6, minute: 0),
          sunset: const TimeOfDay(hour: 18, minute: 0),
          onChange: onTimeChanged,
          minuteInterval: TimePickerInterval.FIVE,
        ),
      );
    },
    child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
  );
}

Widget buildLatestQuote(
    BuildContext context,
    String quote,
    String author,
    ) {
  return Padding(
    padding: const EdgeInsets.all(2.0),
    child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    '$quote',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '- $author',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget buildNoQuotes() {
  return const Text(
    "No quotes",
    style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
  );
}

Widget buildCancelButton({
  required VoidCallback onCancel,
}) {
  return TextButton(
    onPressed: onCancel,
    child: const Text("Cancel Notifications", style: TextStyle(fontSize: 12),),
    style: ButtonStyle(foregroundColor: MaterialStateProperty.all(AppColors.appColor)),
  );
}