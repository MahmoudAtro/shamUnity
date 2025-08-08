// import 'dart:io';
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:path/path.dart' show basename;
// import 'package:shamunity/constants/colors.dart';

// // ignore: must_be_immutable
// class ImgPicker extends StatefulWidget {
//   final void Function(File? imgData, String? imgName) getImgData;
//   final bool isCountry;
//   final IconData? icon;
//   final Color? iconColor;
//   final bool isCreate;
//   final String? backImage;
//   final File? initialImage;
//   bool? isUploadImg;
//   final Function(bool)? upload;

//   ImgPicker({
//     super.key,
//     this.icon,
//     this.iconColor,
//     required this.getImgData,
//     required this.isCountry,
//     this.isUploadImg,
//     required this.isCreate,
//     this.backImage,
//     this.initialImage,
//     this.upload,
//   });

//   @override
//   State<ImgPicker> createState() => _ImgUserState();
// }

// class _ImgUserState extends State<ImgPicker> {
//   String? imgName;
//   String imgUser = "assets/images/userimage.jpg";
//   String imgCountry = "assets/images/squar.png";
//   File? imgData;

//   @override
//   void initState() {
//     imgData = widget.initialImage;
//     super.initState();
//   }

//   uploadImage2Screen({
//     required ImageSource source,
//     required BuildContext context,
//   }) async {
//     Navigator.pop(context);
//     final pickedImg = await ImagePicker().pickImage(source: source);

//     try {
//       if (pickedImg != null) {
//         imgName = basename(pickedImg.path);
//         int random = Random().nextInt(9999999);
//         imgName = "$random$imgName";
//         setState(() {
//           widget.isUploadImg = true;
//           imgData = File(pickedImg.path);
//           widget.getImgData(imgData, imgName);
//           widget.upload!(true);
//         });
//         // getImageBinary();
//       } else {
//         print('NO img selected');
//       }
//     } catch (e) {
//       print('Error => $e');
//     }
//   }

//   showmodel({
//     required BuildContext context,
//   }) {
//     return showModalBottomSheet(
//       context: context,
//       builder: (context) {
//         return Container(
//           padding: const EdgeInsets.all(10),
//           height: 230.h,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               ListTile(
//                 onTap: () async {
//                   await uploadImage2Screen(
//                       source: ImageSource.camera, context: context);
//                 },
//                 leading: const Icon(Icons.photo_camera),
//                 title: const Text('التقط صورة من الكاميرا'),
//               ),
//               ListTile(
//                 onTap: () async {
//                   await uploadImage2Screen(
//                       source: ImageSource.gallery, context: context);
//                 },
//                 leading: const Icon(Icons.photo),
//                 title: const Text('إختر صورة من المعرض'),
//               ),
//               const SizedBox(height: kTextTabBarHeight),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: Alignment.center,
//       child: widget.isCountry
//           ? Stack(
//               children: [
//                 widget.isUploadImg!
//                     ? customCountryImg(true, false, imgFile: imgData)
//                     : widget.isCreate
//                         ? customCountryImg(false, false, urlImg: imgCountry)
//                         : customCountryImg(false, true,
//                             urlImg: widget.backImage),
//                 Positioned(
//                   top: 5.h,
//                   right: 5.w,
//                   child: IconButton(
//                     onPressed: () async {
//                       await showmodel(context: context);
//                     },
//                     icon: CircleAvatar(
//                       radius: 12,
//                       backgroundColor: Colors.white,
//                       child: Icon(
//                         widget.isUploadImg!
//                             ? Icons.edit
//                             : Icons.add_circle_outlined,
//                         size: 18,
//                         color: ColorsManager.btncolor,
//                       ),
//                     ),
//                   ),
//                 )
//               ],
//             )
//           : Stack(
//               children: [
//                 widget.isUploadImg!
//                     ? customUserImg(true, false, imgFile: imgData)
//                     : widget.isCreate
//                         ? customUserImg(false, false, urlImg: imgUser)
//                         : customUserImg(false, true, urlImg: widget.backImage),
//                 Positioned(
//                     top: 5.h,
//                     right: 5.w,
//                     child: InkWell(
//                       onTap: () async {
//                         await showmodel(context: context);
//                       },
//                       child: Container(
//                         alignment: Alignment.center,
//                         height: 20.h,
//                         width: 20.w,
//                         decoration: const BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: Colors.white,
//                         ),
//                         child: Icon(
//                           widget.isUploadImg!
//                               ? Icons.edit
//                               : Icons.add_circle_outlined,
//                           size: 15,
//                           color: widget.iconColor ?? ColorsManager.lightGray,
//                         ),
//                       ),
//                     ))
//               ],
//             ),
//     );
//   }
// }

// Widget customUserImg(bool isFull, bool isUpdate,
//     {String? urlImg, File? imgFile}) {
//   return Container(
//     height: 110.h,
//     width: 110.w,
//     decoration: BoxDecoration(
//       shape: BoxShape.circle,
//       border: Border.all(color: Colors.blue),
//       image: DecorationImage(
//           image: isFull
//               ? FileImage(imgFile!)
//               : isUpdate
//                   ? NetworkImage("${ApiConstances.imageUrl}=$urlImg")
//                   : AssetImage(urlImg!),
//           fit: BoxFit.contain),
//     ),
//   );
// }

// Widget customCountryImg(bool isFull, bool isUpdate,
//     {String? urlImg, File? imgFile}) {
//   return Container(
//     width: 242.w,
//     height: 160.h,
//     margin: EdgeInsets.symmetric(horizontal: 5.w),
//     decoration: BoxDecoration(
//       borderRadius: BorderRadius.circular(16),
//       image: DecorationImage(
//           image: isFull
//               ? FileImage(imgFile!)
//               : isUpdate
//                   ? NetworkImage("${ApiConstances.imageUrl}=$urlImg")
//                   : AssetImage(urlImg!),
//           fit: BoxFit.contain),
//     ),
//     alignment: Alignment.topRight,
//   );
// }
