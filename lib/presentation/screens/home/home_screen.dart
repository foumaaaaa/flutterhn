// presentation/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/article_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../widgets/common/error_widget.dart';
import 'widgets/article_list_item.dart';
import 'widgets/loading_shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  late AnimationController _headerAnimationController;
  late Animation<double> _headerFadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _scrollController = ScrollController();
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _headerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: Curves.easeOutBack,
      ),
    );

    _scrollController.addListener(_onScroll);

    // Load initial data with animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      _headerAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _headerAnimationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Load more articles for Top Stories
      if (_tabController.index == 0) {
        context.read<ArticleProvider>().loadTopStories();
      }
    }
  }

  void _loadData() {
    final articleProvider = context.read<ArticleProvider>();
    final favoritesProvider = context.read<FavoritesProvider>();

    articleProvider.loadTopStories(refresh: true);
    favoritesProvider.loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 120,
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                background: FadeTransition(
                  opacity: _headerFadeAnimation,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors:
                            isDark
                                ? [
                                  const Color(0xFF1F2937),
                                  const Color(0xFF111827),
                                ]
                                : [
                                  const Color(0xFF6366F1),
                                  const Color(0xFF8B5CF6),
                                ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            child: const Icon(
                              Icons.dynamic_feed_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Hacker News',
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.5,
                                      ),
                                ),
                                Text(
                                  'Découvrez les dernières actualités tech',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withOpacity(0.8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _ModernTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  dividerColor: Colors.transparent,
                  indicatorColor: Colors.transparent,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                  tabs: [
                    _buildTab(
                      'Top Stories',
                      Icons.trending_up_rounded,
                      const Color(0xFF6366F1),
                    ),
                    _buildTab(
                      'Nouveau',
                      Icons.fiber_new_rounded,
                      const Color(0xFF10B981),
                    ),
                    _buildTab(
                      'Ask HN',
                      Icons.help_rounded,
                      const Color(0xFFEC4899),
                    ),
                    _buildTab(
                      'Show HN',
                      Icons.visibility_rounded,
                      const Color(0xFFF59E0B),
                    ),
                    _buildTab(
                      'Jobs',
                      Icons.work_rounded,
                      const Color(0xFFEF4444),
                    ),
                  ],
                  onTap: (index) => _onTabChanged(index),
                ),
                theme,
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildTopStoriesTab(),
            _buildNewStoriesTab(),
            _buildAskStoriesTab(),
            _buildShowStoriesTab(),
            _buildJobStoriesTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String text, IconData icon, Color color) {
    return Tab(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onTabChanged(int index) {
    final articleProvider = context.read<ArticleProvider>();

    switch (index) {
      case 1:
        articleProvider.loadNewStories();
        break;
      case 2:
        articleProvider.loadAskStories();
        break;
      case 3:
        articleProvider.loadShowStories();
        break;
      case 4:
        articleProvider.loadJobStories();
        break;
    }
  }

  Widget _buildTopStoriesTab() {
    return Consumer<ArticleProvider>(
      builder: (context, provider, child) {
        if (provider.status == ArticleStatus.initial) {
          return const LoadingShimmer();
        }

        if (provider.status == ArticleStatus.error) {
          return CustomErrorWidget(
            message: provider.errorMessage ?? 'Une erreur est survenue',
            onRetry: () => provider.loadTopStories(refresh: true),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadTopStories(refresh: true),
          color: const Color(0xFF6366F1),
          backgroundColor: Theme.of(context).colorScheme.surface,
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount:
                provider.articles.length + (provider.hasMoreArticles ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == provider.articles.length) {
                return Container(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                );
              }

              final article = provider.articles[index];
              return ArticleListItem(article: article);
            },
          ),
        );
      },
    );
  }

  Widget _buildNewStoriesTab() {
    return Consumer<ArticleProvider>(
      builder: (context, provider, child) {
        return _buildStoryList(
          provider.newStories,
          provider.isLoading,
          const Color(0xFF10B981),
        );
      },
    );
  }

  Widget _buildAskStoriesTab() {
    return Consumer<ArticleProvider>(
      builder: (context, provider, child) {
        return _buildStoryList(
          provider.askStories,
          provider.isLoading,
          const Color(0xFFEC4899),
        );
      },
    );
  }

  Widget _buildShowStoriesTab() {
    return Consumer<ArticleProvider>(
      builder: (context, provider, child) {
        return _buildStoryList(
          provider.showStories,
          provider.isLoading,
          const Color(0xFFF59E0B),
        );
      },
    );
  }

  Widget _buildJobStoriesTab() {
    return Consumer<ArticleProvider>(
      builder: (context, provider, child) {
        return _buildStoryList(
          provider.jobStories,
          provider.isLoading,
          const Color(0xFFEF4444),
        );
      },
    );
  }

  Widget _buildStoryList(
    List<dynamic> stories,
    bool isLoading,
    Color accentColor,
  ) {
    if (isLoading && stories.isEmpty) {
      return const LoadingShimmer();
    }

    if (stories.isEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accentColor.withOpacity(0.1),
                accentColor.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: accentColor.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [accentColor, accentColor.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.inbox_rounded,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Aucun article disponible',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Implement refresh for specific story type
        final articleProvider = context.read<ArticleProvider>();
        switch (accentColor.value) {
          case 0xFF10B981: // Green - New Stories
            articleProvider.loadNewStories();
            break;
          case 0xFFEC4899: // Pink - Ask Stories
            articleProvider.loadAskStories();
            break;
          case 0xFFF59E0B: // Amber - Show Stories
            articleProvider.loadShowStories();
            break;
          case 0xFFEF4444: // Red - Job Stories
            articleProvider.loadJobStories();
            break;
        }
      },
      color: accentColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: stories.length,
        itemBuilder: (context, index) {
          final article = stories[index];
          return ArticleListItem(article: article);
        },
      ),
    );
  }
}

class _ModernTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final ThemeData theme;

  _ModernTabBarDelegate(this.tabBar, this.theme);

  @override
  double get minExtent => tabBar.preferredSize.height + 20;
  @override
  double get maxExtent => tabBar.preferredSize.height + 20;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors:
              isDark
                  ? [const Color(0xFF1F2937), const Color(0xFF111827)]
                  : [const Color(0xFFF8FAFC), const Color(0xFFFFFFFF)],
        ),
        boxShadow: [
          BoxShadow(
            color:
                isDark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        child: tabBar,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
