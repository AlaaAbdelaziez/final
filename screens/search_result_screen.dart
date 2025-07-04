// ignore_for_file: prefer_const_constructors, avoid_print

import 'package:citio/screens/product_details_view.dart';
import 'package:citio/screens/service_order_screen.dart';
import 'package:citio/screens/subcategory_screen.dart';
import 'package:citio/screens/vendor_profile.dart';
import 'package:flutter/material.dart';
import 'package:citio/helper/api_search.dart';
import 'package:citio/models/search_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchResultsPage extends StatefulWidget {
  final String keyword;

  const SearchResultsPage({super.key, required this.keyword});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  List<SearchResultModel>? _results;
  bool _isLoading = true;
  String? _error;
  static const baseImageUrl = "https://service-provider.runasp.net";

  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.keyword);
    _performSearch(widget.keyword);
  }

  Future<void> _performSearch(String keyword) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await ApiSearch.search(keyword);
      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text("نتائج البحث")),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: Column(
          children: [
            // ✅ شريط البحث
            SizedBox(
              height: 42.h,
              child: TextField(
                controller: _controller,
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    _performSearch(value.trim());
                  }
                },
                style: TextStyle(fontSize: 14.sp),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0.h,
                    horizontal: 16.w,
                  ),
                  hintText: 'ماذا تريد؟',
                  prefixIcon: InkWell(
                    onTap: () {
                      if (_controller.text.trim().isNotEmpty) {
                        _performSearch(_controller.text.trim());
                      }
                    },
                    child: Icon(Icons.search, size: 20.sp),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(20.0.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black87),
                    borderRadius: BorderRadius.circular(20.0.r),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // ✅ محتوى نتائج البحث
            if (_isLoading)
              Center(child: CircularProgressIndicator())
            else if (_error != null)
              Center(child: Text('❌ خطأ: $_error'))
            else if (_results == null || _results!.isEmpty)
              Center(child: Text("لا توجد نتائج"))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _results!.length,
                itemBuilder: (context, index) {
                  final result = _results![index];
                  return InkWell(
                    onTap: () {
                      final type = result.type.toLowerCase();

                      if (type == 'product') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ProductDetailsView(
                                  productId: int.parse(result.id),
                                ),
                          ),
                        );
                      } else if (type == 'subcategory') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => SubCategoryScreen(
                                  selectedSubCategoryIndex: int.parse(
                                    result.id,
                                  ),
                                  selectedCategoryIndex: result.categoryId!,
                                ),
                          ),
                        );
                      } else if (type == 'category') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ServiceOrderScreen(),
                          ),
                        );
                      } else if (type == 'vendor') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VendorProfile(id: result.id),
                          ),
                        );
                      }
                    },
                    child: Card(
                      margin: EdgeInsets.symmetric(vertical: 8.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 12.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (result.imageUrl != null &&
                                result.imageUrl!.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.r),
                                child: Image.network(
                                  "$baseImageUrl${result.imageUrl!}",
                                  height: 180.h,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.network(
                                      'https://cdn-icons-png.flaticon.com/512/13434/13434972.png',
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ),
                              )
                            else
                              Container(
                                height: 180.h,
                                color: Colors.grey[200],
                                child: Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 50.sp,
                                  ),
                                ),
                              ),
                            SizedBox(height: 10.h),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    result.nameAr ?? "بدون اسم",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.sp,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (result.type.toLowerCase() == "product")
                                  Text(
                                    result.price != null
                                        ? "LE ${result.price!.toStringAsFixed(2)}"
                                        : "",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    result.categoryNameAr ?? "بدون تصنيف",
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: Colors.grey[700],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (result.businessName != null &&
                                    result.businessName!.isNotEmpty)
                                  Text(
                                    result.businessName!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
