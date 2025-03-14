import { getPlayLists } from "../../api/playListApi"
import { PlayList } from "../../common/entities/PlayList"
import { PlayListCard, PlayListCard_Skeleton } from "../cards/PlayListCard"
import { DialogUtil, LogUtil, ToastUtil } from "@pura/harmony-utils";
import { Announcement } from "../../common/entities/Announcement";
import { User, UserClass } from "../../common/entities/User";
import Constants from "../../common/constants/Constants";
import { StorageConstants } from "../../common/constants/StorageConstants";
import {
  ItemRestriction,
  SegmentButton, SegmentButtonOptions, SegmentButtonTextItem } from "@ohos.arkui.advanced.SegmentButton";

/**
 * 用户歌单
 */
@Component
export struct UserPlayLists {
  tabsController: TabsController = new TabsController()
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp(StorageConstants.USER) user: User = UserClass
  @StorageProp(StorageConstants.BREAKPOINT) breakpoint: string = 'sm'
  @StorageProp(StorageConstants.IS_LOGGED) @Watch('getPlayLists') isLogged: boolean = false
  @StorageProp('Announcement') announcement: Announcement = {
    code: -1,
    data: { title:'', content: '' },
    visible: false
  }
  @StorageProp(StorageConstants.USER_PLAYLISTS) playLists: Array<PlayList> = []
  @State isLoading: boolean = false
  @State isRefreshing: boolean = false
  @State lastRefreshTime: number = 0
  @State tabsIndex: number = 0
  @State segmentTabsIndex: number[] = [0]
  @State segmentOption: SegmentButtonOptions = SegmentButtonOptions.tab({
    buttons: [{ text: '所有歌单' }, { text: '我创建的' }, {
      text: '我收藏的'
    }] as ItemRestriction<SegmentButtonTextItem>,
    selectedBackgroundColor: $r('app.color.segment_selected_bg')
  })
  private refreshCooldown: number = 5000

  async aboutToAppear(): Promise<void> {
    try {
      setTimeout(async () => {
        await this.getPlayLists()
      }, 100)
    } catch (e) {
      ToastUtil.showToast('获取歌单列表失败')
      LogUtil.error('Error fetching playlists: ', e.message)
    } finally {
      this.isLoading = false
    }
  }

  async getPlayLists() {
    if(this.isLogged && this.user && this.playLists.length == 0) {
      this.isLoading = true
      const playlist = await getPlayLists(0)
      this.playLists = playlist.playlist
      this.isLoading = false
    }
    else return
  }

  build() {
    Column() {
      if(this.isLogged) {
        this.TabBar()
        Refresh({ refreshing: this.isRefreshing}) {
          Tabs({ controller: this.tabsController }) {
            TabContent() {
              List() {
                ListItem().height(12)
                ForEach(this.playLists, (item: PlayList, index) => {
                  ListItem() {
                    PlayListCard({
                      playList: item,
                      isShowHeart: item.creator?.userId == this.user.data?.account.id ? false : true
                    })
                      .padding( this.breakpoint == 'md' ? 5 : { bottom: 10 } )
                  }
                })
                ListItem().height(px2vp(this.bottomRectHeight) + 160)
              }
              .contentListStyle(this.breakpoint)
            }.padding({left: 12, right: 12})
            TabContent() {
              List() {
                ListItem().height(12)
                ForEach(this.playLists.filter((item) => item.userId === this.user.data.account.id),
                  (item: PlayList, index) => {
                    ListItem() {
                      PlayListCard({
                        playList: item,
                        isShowHeart: item.creator?.userId == this.user.data?.account.id ? false : true
                      })
                        .padding( this.breakpoint == 'md' ? 5 : { bottom: 10 } )
                    }
                  })
                ListItem().height(px2vp(this.bottomRectHeight) + 160)
              }
              .contentListStyle(this.breakpoint)
            }.padding({left: 12, right: 12})
            TabContent() {
              List() {
                ListItem().height(12)
                ForEach(this.playLists.filter((item) => item.userId !== this.user.data.account.id),
                  (item: PlayList, index) => {
                  ListItem() {
                    PlayListCard({
                      playList: item,
                      isShowHeart: item.creator?.userId == this.user.data?.account.id ? false : true
                    })
                      .padding( this.breakpoint == 'md' ? 5 : { bottom: 10 } )
                  }
                })
                ListItem().height(px2vp(this.bottomRectHeight) + 160)
              }
              .contentListStyle(this.breakpoint)
            }.padding({left: 12, right: 12})
          }
          .barHeight(0)
          .onAnimationStart((_index, target) => {
            animateTo({
              duration: 250
            }, () => {
              this.segmentTabsIndex[0] = target
            })
          })
        }
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        .onRefreshing(async () => {
          await this.refreshContent()
        })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder TabBar() {
    Row() {
      SegmentButton({
        selectedIndexes: $segmentTabsIndex,
        options: this.segmentOption,
        onItemClicked: (val) => {
          this.tabsController.changeIndex(val)
        }
      })
    }.margin({bottom: 16, top: 6, left: 12, right: 12})
  }

  // @Builder TabBarButtonItem(title: string, index: number) {
  //   Button() {
  //     Text(title)
  //       .fontColor(this.tabsIndex === index ? gAppTheme.colors?.brand : Color.Gray)
  //       .fontWeight(FontWeight.Medium)
  //   }
  //   .layoutWeight(1)
  //   .backgroundColor(Color.Transparent)
  //   .padding(Constants.PADDING_EDGE_DEFAULT)
  //   .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.7 })
  //   .onClick(() => { this.tabsController.changeIndex(index) })
  // }

  @Builder PlayListsContent(list: PlayList[]) {
    List() {
      ForEach(list, (item: PlayList, index) => {
        ListItem() {
          PlayListCard({
            playList: item,
            isShowHeart: item.creator?.userId == this.user.data?.account.id ? false : true
          })
            .padding( this.breakpoint == 'md' ? 5 : { bottom: 10 } )
        }
      })
      ListItem().height(px2vp(this.bottomRectHeight) + 160)
    }
    .height('100%')
    .width('100%')
    .scrollBar(BarState.Off)
    .lanes(this.breakpoint == 'md' ? 2 : 1)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder
  Loading() {
    ForEach([1, 2, 3, 4, 5, 6, 7, 8, 9, 10], () => {
      PlayListCard_Skeleton()
    })
  }

  private async refreshContent() {
    if (this.isLogged) {
      this.isRefreshing = true
      const currentTime = new Date().getTime()
      if (currentTime - this.lastRefreshTime < this.refreshCooldown) {
        ToastUtil.showToast('操作过于频繁，请5秒后再试')
      } else {
        try {
          const result = await getPlayLists(0)
          this.playLists = result.playlist
          this.lastRefreshTime = currentTime
          ToastUtil.showToast('刷新成功')
        } catch (e) {
        }
      }
      this.isRefreshing = false
    }
    else return
  }
}

@Extend(List) function contentListStyle(breakpoint: string) {
    .height('100%')
    .scrollBar(BarState.Off)
    .lanes(breakpoint == 'md' ? 2 : 1)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  .backgroundColor($r('sys.color.comp_background_list_card'))
  .borderRadius(24)
}