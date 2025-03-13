import { ToastUtil } from '@pura/harmony-utils';
import { BottomBarComponent } from '../components/play/BottomBarComponent';
import { SearchPlayListsList } from '../components/lists/SearchPlayListsList';
import { SearchSongsList } from '../components/lists/SearchSongsList';
import Constants from '../common/constants/Constants';
import { StorageConstants } from '../common/constants/StorageConstants';
import { resourceManager } from '@kit.LocalizationKit';
import { SearchHistoryComponent } from '../components/lists/SearchHistoryComponent';

/**
 * 歌曲列表页（搜索结果）
 */
const TAG = "[SearchPage] "

@Component
export struct SearchPage {
  @StorageProp(StorageConstants.BREAKPOINT) breakpoint: string = 'sm'
  @StorageLink(StorageConstants.SEARCH_HISTORY) searchHistory: string[] = []
  @State tabPageIndex: number = 0
  @State keyword: string = ''
  @State @Watch('syncKeyword') searchKeyword: string = ''
  private tabsController: TabsController = new TabsController()
  private searchController: SearchController = new SearchController()

  syncKeyword() {
    this.keyword = this.searchKeyword
    this.searchController.stopEditing()
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        Stack({ alignContent: Alignment.Top }) {
          if(this.searchKeyword != '') {
            Column({ space: 10 }) {
              this.TabBar()
              Tabs({ controller: this.tabsController }) {
                TabContent() { SearchSongsList({ searchKeyword: this.searchKeyword }) }.expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
                TabContent() { SearchPlayListsList({ searchKeyword: this.searchKeyword }) }.expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
              }
              .layoutWeight(1)
              .onChange((index) => {
                this.tabPageIndex = index
              })
              .scrollable(false)
              .barHeight(0)
            }
            .height('100%')
            .width('100%')
          }
          else {
            SearchHistoryComponent({ searchKeyword: this.searchKeyword })
          }
        }
        .height('100%')

        if(this.breakpoint !== 'lg') {
          BottomBarComponent()
            .padding(Constants.PADDING_EDGE_DEFAULT)
            .backgroundColor(Color.Transparent)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('sys.color.background_secondary'))
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .title(this.Head())
  }

  /**
   * TabBar
   */
  @Builder
  TabBarButton(content: string, toIndex: number) {
    Button() {
      Text(content)
        .fontColor(this.tabPageIndex == toIndex ? '#ffee6f6f' : $r('app.color.reverse'))
        .fontWeight(FontWeight.Medium)
    }
    .layoutWeight(1)
    .padding({ left: 10, right: 10, top: 5, bottom: 5 })
    .backgroundColor(Color.Transparent)
    .animation({ duration: 200 })
    .onClick(() => {
      this.tabsController.changeIndex(toIndex)
    })
  }

  @Builder
  TabBar() {
    Row({ space: 5 }) {
      this.TabBarButton('单曲', 0)
      this.TabBarButton('歌单', 1)
    }
    .width('80%')
    .justifyContent(FlexAlign.SpaceAround)
  }

  @Builder
  Head() {
    Column() {
      Search({
        placeholder: '搜索内容',
        value: this.keyword,
        icon: '/resources/base/media/ic_public_search_filled.svg',
        controller: this.searchController
      })
        .defaultFocus(true)
        .layoutWeight(1)
        .searchButton('搜索')
        .onChange((value) => {
          if(!value) {
            this.searchKeyword = ''
          }
        })
        .onSubmit(async (value) => {
          if (!value) {
            ToastUtil.showToast('请输入搜索内容')
          } else {
            this.searchKeyword = value
            this.searchHistory = this.searchHistory.filter((item) => item !== value)
            this.searchHistory.unshift(value)
            this.tabPageIndex = 0
          }
        })
    }
    .padding({ left: Constants.PADDING_EDGE_DEFAULT })
  }
}