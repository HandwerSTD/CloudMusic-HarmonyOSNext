import { Explore } from '../components/main/Explore'
import { BottomBarComponent } from '../components/play/BottomBarComponent';
import Constants from '../common/constants/Constants';
import { SettingsPage } from './SettingsPage';
import { CachedPage } from './CachedPage';
import { CloudPage } from './CloudPage';
import { DailyListPage } from './DailyListPage';
import { SearchPage } from './SearchPage';
import { PlayListPage } from './PlayListPage';
import { PlayListPageParam, WebPageParam } from '../common/entities/PageParams';
import { LoginPage } from './login/LoginPage';
import { QrCodeLogin } from './login/QrCodeLogin';
import { WebLogin } from './login/WebLogin';
import { WebPage } from './WebPage';
import { UserPlayLists } from '../components/main/UserPlayLists';
import { Me } from '../components/main/Me';
import { resourceManager } from '@kit.LocalizationKit';
import { StorageConstants } from '../common/constants/StorageConstants';
import { WarrantyDialog } from '../components/dialog/WarrantyDialog';
import { TopListPage } from './TopListPage';
import { ApiDialog } from '../components/dialog/ApiDialog';
import PreferencesUtils from '../common/utils/data/PreferencesUtils';
import { DebugPage } from './DebugPage';
import BreakpointUtils from '../common/utils/system/BreakpointUtils';
import { ThemeControl } from '@kit.ArkUI';
import { gAppTheme } from '../common/utils/theme/ThemeUtils';

ThemeControl.setDefaultTheme(gAppTheme)

@Entry
@Component
struct Index {
  warrantyDialogController: CustomDialogController = new CustomDialogController({
    builder: WarrantyDialog(),
    autoCancel: false
  })

  apiDialogController: CustomDialogController = new CustomDialogController({
    builder: ApiDialog(),
    autoCancel: false
  })

  tabController: TabsController = new TabsController()

  @StorageProp('topRectHeight') topRectHeight: number = 0
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp(StorageConstants.BREAKPOINT) breakpoint: string = 'sm'
  @StorageProp(StorageConstants.DEFAULT_PAGE_INDEX) index: number = 0
  @StorageProp(StorageConstants.VALID_API_URL) @Watch('checkApi') validApiUrl: boolean = true
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack()
  @State tabCurrentIndex: number = 0

  private getMenuItems(): NavigationMenuItem[] {
    let items: NavigationMenuItem[] = []
    if(this.index == 0 || this.index == 1) {
      items.push({
        value: 'Search',
        icon: $r('app.media.ic_public_search_filled'),
        action: () => {
          this.pageInfos.clear()
          this.pageInfos.pushPathByName('SearchPage', null, true)
        }
      })
    }
    // if(this.index == 1) {
    //   items.unshift({
    //     value: 'Add',
    //     icon: $r('app.media.ic_public_add_filled'),
    //     action: () => {
    //       this.addPlayListController.open()
    //     }
    //   })
    // }
    return items
  }

  checkApi() {
    if(!this.validApiUrl) {
      this.apiDialogController.open()
    }
  }

  async aboutToAppear(): Promise<void> {
    BreakpointUtils.register()
    setTimeout(() => {
      this.tabCurrentIndex = this.index
    }, 1)
    this.checkApi()
    const isFirstLaunch = await PreferencesUtils.getPreferenceValue<boolean>(StorageConstants.USER_PREF, 'isFirstLaunch', true)
    if(isFirstLaunch) {
      this.apiDialogController.open()
      this.warrantyDialogController.open()
      PreferencesUtils.putPreferenceValue(StorageConstants.USER_PREF, 'isFirstLaunch', false)
    }
  }

  aboutToDisappear(): void {
    BreakpointUtils.unregister()
  }

  async build() {
    Navigation(this.pageInfos) {
      Stack({ alignContent: Alignment.Bottom }) {
        Tabs({ controller: this.tabController, index: $$this.tabCurrentIndex }) {
          TabContent() { Explore() }
          TabContent() { UserPlayLists() }
          TabContent() { Me() }
        }
        .height('100%')
        .width('100%')
        .barHeight(0)
        .edgeEffect(EdgeEffect.None)
        .animationDuration(300)
        .onAnimationStart((from, target) => {
          this.index = target
        })

        BottomBarComponent()
          .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT, bottom: px2vp(this.bottomRectHeight) + 45 })
          .backgroundColor(Color.Transparent)
      }
    }
    .height('100%')
    .width('100%')
    .navBarWidth('50%')
    .navBarPosition(NavBarPosition.Start)
    .mode(this.breakpoint == 'lg' ? NavigationMode.Split : NavigationMode.Stack)
    .titleMode(NavigationTitleMode.Mini)
    .title(this.index == 0 ? '发现' : this.index == 1 ? '歌单' : '我的')
    .menus(this.getMenuItems())
    .hideBackButton(true)
    .backgroundColor($r('sys.color.background_secondary'))
    .navDestination(this.PageMap)
    .toolbarConfiguration(this.ToolBar(), { backgroundBlurStyle: BlurStyle.Regular, barStyle: BarStyle.STACK, backgroundColor: $r('sys.color.comp_background_secondary') })
  }

  @Builder PageMap(name: string, param: Object) {
    if(name === 'SettingsPage') {
      SettingsPage()
    }
    else if(name === 'DownloadPage') {
      CachedPage()
    }
    else if(name === 'CloudPage') {
      CloudPage()
    }
    else if(name === 'DailyListPage') {
      DailyListPage()
    }
    else if(name === 'SearchPage') {
      SearchPage()
    }
    else if(name === 'PLayListPage') {
      PlayListPage({ param: param as PlayListPageParam })
    }
    else if(name === 'LoginPage') {
      LoginPage()
    }
    else if(name === 'QrCodeLogin') {
      QrCodeLogin()
    }
    else if(name === 'WebLogin') {
      WebLogin()
    }
    else if(name === 'WebPage') {
      WebPage({ param: param as WebPageParam })
    }
    else if(name == 'TopListPage') {
      TopListPage()
    }
    else if(name == 'DebugPage') {
      DebugPage()
    }
  }

  @Builder ToolBar() {
    Row() {
      this.ToolBarItem(0, $r('app.media.ic_gallery_discover'), $r('app.media.ic_gallery_discover_filled'), '发现')
      this.ToolBarItem(1, $r('app.media.ic_public_drawer'), $r('app.media.ic_public_drawer_filled'),'歌单')
      this.ToolBarItem(2, $r('app.media.ic_public_contacts'), $r('app.media.ic_public_contacts_filled'), '我的')
    }
    .backgroundColor(Color.Transparent)
    .justifyContent(FlexAlign.SpaceEvenly)
    .width('100%')
  }

  @Builder ToolBarItem(index: number, icon: ResourceStr, activeIcon: ResourceStr, text: string) {
    Column({ space: 3 }) {
      Image(this.index == index ? activeIcon : icon)
        .width(Constants.SIZE_ICON_BUTTON_BAR)
        .fillColor(this.index == index ? gAppTheme.colors?.brand : Color.Gray)
      Text(text)
        .fontSize(Constants.FONT_SIZE_BAR)
        .fontColor(this.index == index ? gAppTheme.colors?.brand : Color.Gray)
    }
    .layoutWeight(1)
    .onClick(() => {
      this.tabController.changeIndex(index)
    })
  }
}