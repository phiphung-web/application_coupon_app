import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../data/repo/category_repo.dart';
import '../../data/impl/category_repo_remote.dart';
import '../../widgets/app_image.dart';

class CouponCategoriesScreen extends StatefulWidget {
  const CouponCategoriesScreen({super.key});
  @override
  State<CouponCategoriesScreen> createState() => _CouponCategoriesScreenState();
}

class _CouponCategoriesScreenState extends State<CouponCategoriesScreen> {
  final CategoryRepo _repo = CategoryRepoRemote();
  List<Category> _cats = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await _repo.list();
    if (!mounted) return;
    setState(() {
      _cats = list;
      _loading = false;
    });
  }

  String _imgFor(Category c) => 'https://picsum.photos/seed/couponCat${c.id}/400/300';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Danh mục mã')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.0, // fix overflow
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _cats.length,
                itemBuilder: (_, i) {
                  final c = _cats[i];
                  return InkWell(
                    onTap: () => Navigator.pop<int>(context, c.id),
                    borderRadius: BorderRadius.circular(12),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: AppImage(_imgFor(c),
                                  w: double.infinity, h: double.infinity, fit: BoxFit.cover),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              child: Text(
                                c.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
