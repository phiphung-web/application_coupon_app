import 'package:flutter/material.dart';

import '../../data/impl/shop_repo_remote.dart';
import '../../data/repo/shop_repo.dart';
import '../../models/shop.dart';
import '../../services/favorites_service.dart';
import '../../services/notification_prefs_service.dart';

class SourcesScreen extends StatefulWidget {
  const SourcesScreen({super.key});

  @override
  State<SourcesScreen> createState() => _SourcesScreenState();
}

class _SourcesScreenState extends State<SourcesScreen> {
  final ShopRepo _repo = ShopRepoRemote();
  final FavoritesService _favorites = FavoritesService.instance;
  final NotificationPrefsService _prefs = NotificationPrefsService.instance;

  List<Shop> _sources = const [];
  bool _loading = true;
  String? _type;
  bool _onlyFollowed = false;
  Set<String> _favoriteSourceIds = {};
  Set<String> _notifySourceIds = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await _repo.list();
    final favorites = await _favorites.all(FavoriteKind.source);
    final notify = await _prefs.sourceIds();
    if (!mounted) return;
    setState(() {
      _sources = list;
      _favoriteSourceIds = favorites.map((e) => e.split('_').last).toSet();
      _notifySourceIds = notify;
      _loading = false;
    });
  }

  Iterable<Shop> get _filtered {
    Iterable<Shop> list = _sources;
    if (_type != null) {
      list = list.where(
        (shop) => shop.type.toUpperCase() == _type!.toUpperCase(),
      );
    }
    if (_onlyFollowed) {
      list = list.where((shop) => _favoriteSourceIds.contains(shop.id));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Nguồn ưu đãi',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _load,
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildFilters(),
          const SizedBox(height: 12),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_filtered.isEmpty)
            const Text('Không tìm thấy nguồn phù hợp.')
          else
            ..._filtered.map(_SourceCard.new),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final types = <String?, String>{
      null: 'Tất cả',
      'ECOM': 'TMĐT',
      'FOOD': 'Ăn uống',
      'TRAVEL': 'Đi lại',
      'APP': 'App mobile',
    };
    return Wrap(
      spacing: 10,
      children: [
        ...types.entries.map(
          (entry) => ChoiceChip(
            label: Text(entry.value),
            selected: _type == entry.key,
            onSelected: (_) => setState(() => _type = entry.key),
          ),
        ),
        FilterChip(
          label: const Text('Nguồn đang theo dõi'),
          selected: _onlyFollowed,
          onSelected: (value) => setState(() => _onlyFollowed = value),
        ),
      ],
    );
  }
}

class _SourceCard extends StatefulWidget {
  final Shop shop;
  const _SourceCard(this.shop);

  @override
  State<_SourceCard> createState() => _SourceCardState();
}

class _SourceCardState extends State<_SourceCard> {
  final FavoritesService _favorites = FavoritesService.instance;
  final NotificationPrefsService _prefs = NotificationPrefsService.instance;

  bool _favorite = false;
  bool _notify = false;

  @override
  void initState() {
    super.initState();
    _hydrate();
  }

  Future<void> _hydrate() async {
    final fav = await _favorites.isFavorite(FavoriteKind.source, widget.shop.id);
    final notify = await _prefs.isSourceEnabled(widget.shop.id);
    if (!mounted) return;
    setState(() {
      _favorite = fav;
      _notify = notify;
    });
  }

  Future<void> _toggleFavorite() async {
    final added =
        await _favorites.toggle(FavoriteKind.source, widget.shop.id);
    if (!mounted) return;
    setState(() => _favorite = added);
  }

  Future<void> _toggleNotify(bool value) async {
    final enabled = await _prefs.toggleSource(widget.shop.id);
    if (!mounted) return;
    setState(() => _notify = enabled);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundImage:
                  widget.shop.logoUrl != null ? NetworkImage(widget.shop.logoUrl!) : null,
              child: widget.shop.logoUrl == null
                  ? const Icon(Icons.storefront)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.shop.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  if (widget.shop.description != null)
                    Text(
                      widget.shop.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    children: [
                      _chip(
                        '${widget.shop.couponCount ?? 0} mã',
                        Icons.confirmation_number,
                      ),
                      _chip(
                        '${widget.shop.itemCount ?? 0} item',
                        Icons.widgets_outlined,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: Icon(
                    _favorite ? Icons.favorite : Icons.favorite_border,
                    color: _favorite ? Colors.pink : null,
                  ),
                  onPressed: _toggleFavorite,
                ),
                Switch(
                  value: _notify,
                  onChanged: _toggleNotify,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 14),
      label: Text(label),
    );
  }
}

