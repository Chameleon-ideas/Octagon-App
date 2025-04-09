import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:octagon/utils/colors.dart' as ColorR;
import 'package:octagon/utils/styles.dart' as StylesR;
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

void showImagePicker(context,
    {Function(ImageSource? imageSource)? onImageSelection}) {
  showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: ColorR.kcBackground,
            border: Border.all(
              color: ColorR.kcLightGreyColor,
              width: 1.0,
            ),
          ),
          child: new Wrap(
            children: <Widget>[
              Column(),
              ListTile(
                  leading: Icon(Icons.photo_library, color: ColorR.kcTealColor),
                  title: Text(
                    "Gallery",
                    style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.normal,
                        color: ColorR.kcIvoryBlackColor),
                  ),
                  onTap: () {
                    onImageSelection?.call(ImageSource.gallery);
                    Navigator.of(context).pop();
                  }),
              ListTile(
                leading:
                    new Icon(Icons.photo_camera, color: ColorR.kcTealColor),
                title: Text("Camera",
                    style: StylesR.kTextStyleRestaurantInfoTitle),
                onTap: () {
                  onImageSelection?.call(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading:
                    new Icon(Icons.photo_camera, color: ColorR.kcTealColor),
                title:
                    Text("Video", style: StylesR.kTextStyleRestaurantInfoTitle),
                onTap: () {
                  onImageSelection?.call(null);
                  Navigator.of(context).pop();
                },
              ),
              StylesR.verticalSpaceMedium,
              ListTile(
                title: Text(
                  "Cancel",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.normal,
                      color: ColorR.kcIvoryBlackColor),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      });
}

Future<String?> getImagePath(String path, {bool isVideo = true}) async {
  try {
    if (path.isEmpty || !isVideo) {
      return path;
    }

    String? thumbnailPath = await VideoThumbnail.thumbnailFile(
      video: path,
      timeMs: 1,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.PNG,
      maxHeight: 250,
      maxWidth: 250,
      quality: 75,
    );
    print(thumbnailPath);
    return thumbnailPath;
  } catch (e) {
    print(e);
    return null;
  }
}
