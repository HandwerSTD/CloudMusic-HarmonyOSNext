import { Song } from '../common/entities/SongsResult'
import { SongCard } from '../components/cards/SongCard'
import { DateUtil, LogUtil } from '@pura/harmony-utils'
import { DailySongRes, PlayDailySongs } from '../api/playListApi'
import { BottomBarComponent } from '../components/play/BottomBarComponent'
import { playQueue } from '../common/functions/play/playControl'
import { AddToPlayListButton } from '../components/buttons/play/AddToPlayListButton'
import { getDailySongs } from '../api/songApi'
import Constants from '../common/constants/Constants'
import { resourceManager } from '@kit.LocalizationKit'
import { StorageConstants } from '../common/constants/StorageConstants'
import { gAppTheme } from '../common/utils/theme/ThemeUtils'

/**
 * 每日推荐歌单页面
 */

const TAG = '[DailyListPage] '

@Component
export struct DailyListPage {
  @StorageProp(StorageConstants.IS_PLAYER_LOADING) isPlayerLoading: boolean = false
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @StorageProp(StorageConstants.BREAKPOINT) breakpoint: string = 'sm'
  @State list: Array<DailySongRes> = new Array()
  @State hasLoaded: boolean = false
  @State isLoading: boolean = true
  @State loadingPlayList:boolean = false
  @State pageOpacity: number = 1
  @State todayDate: string = ''

  async aboutToAppear() {
    if(!this.hasLoaded) {
      await this.loadSongs()
      this.hasLoaded = true
    }
    let date = new Date()
    this.todayDate = `${date.toDateString()}`
  }

  async loadSongs(): Promise<void> {
    this.isLoading = true
    try {
      let result:Array<DailySongRes> = await getDailySongs()
      if(result.length < 3) { result = await getDailySongs(false) }
      this.list = result
    } catch (e) {
      LogUtil.error(TAG + 'Error fetching songs: ', e)
    } finally {
      this.isLoading = false
    }
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        Stack({ alignContent: Alignment.Top }) {
          if (this.isLoading) {
            Column() {
              LoadingProgress().width(Constants.SIZE_LOADING_PROGRESS_DEFAULT)
            }.height('100%').width('100%').justifyContent(FlexAlign.Center)
          } else {
            // debug
            Stack({ alignContent: Alignment.Top}) {
              Column() {
                if(this.list.length < 3) {
                  Text('获取每日歌单失败').fontSize(Constants.FONT_SIZE_COMMON).textAlign(TextAlign.Center)
                }
              }
              .padding({ top: px2vp(this.topRectHeight) + 150, left: 20, right: 20 })

              List() {
                ListItem() {
                  this.Info()
                }
                ListItem() {
                  Button() {
                    Row({ space: 12 }) {
                      if (this.isPlayerLoading) {
                        LoadingProgress().height(35).padding({ left: 30 })
                      } else {
                        SymbolGlyph($r('sys.symbol.play_round_triangle_fill')).fontSize(36).fontColor([gAppTheme.colors?.brand])
                        Text(`播放全部 (${this.list.length})`).fontSize(18).fontWeight(FontWeight.Bold)
                      }
                    }
                    .height(Constants.HEIGHT_TEXT_BUTTON)
                    .margin({left: 12, right: 12})
                  }
                  .type(ButtonType.Normal)
                  .backgroundColor(Color.Transparent)
                  .borderRadius(Constants.RADIUS_BUTTON)
                  .onClick(async () => {
                    this.loadingPlayList = true
                    await PlayDailySongs()
                    this.loadingPlayList = false
                    playQueue(0)
                  })
                }
                .padding({ left: 20, bottom: 10 })

                ListItemGroup({space: 12}) {
                  ForEach(this.list, (item: DailySongRes, index) => {
                    ListItem() {
                      SongCard({
                        song: item.song,
                        sid: index,
                        isPlayList: false,
                        index: index,
                        reason: item.reason,
                        picUrl: item.picUrl ?? $r('app.media.ic_public_music')
                      })
                    }
                    .swipeAction({ end: this.SwipeItem(item.song) })
                    .translate({ y: -40 })
                    .animation({
                      duration: 600,
                      curve: Curve.LinearOutSlowIn
                    })
                    .translate({ y: 0 })
                  })
                }

                ListItem().height(px2vp(this.bottomRectHeight) + Constants.HEIGHT_MINI)
              }
              .height('100%')
              .layoutWeight(1)
              .width('100%')
              .scrollBar(BarState.Auto)
              .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
            }
            .height('100%')
            .layoutWeight(1)
            .width('100%')
          }
        }
        .height('100%')

        if(this.breakpoint !== 'lg') {
          BottomBarComponent()
            .padding(Constants.PADDING_EDGE_DEFAULT)
            .backgroundColor(Color.Transparent)
        }

        if(this.loadingPlayList) {
          Column() {
            Column({ space: 10 }) {
              LoadingProgress().width(60)
              Text('正在获取完整歌曲列表')
            }
            .padding(30)
            .borderRadius(15)
            .backgroundColor($r('app.color.main'))
          }
          .height('100%')
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .padding({ bottom: px2vp(this.topRectHeight) })
        }
      }
      .opacity(this.pageOpacity)
      .width('100%')
      .height('100%')
      .backgroundColor($r('sys.color.background_secondary'))
    }
    .title('每日推荐')
    .backgroundColor($r('sys.color.background_secondary'))
  }

  @Builder
  Info() {
    Column() {
      if (this.list.length > 3) {
        this.StackedAlbum()
      } else {
        Image($r('app.media.bg_daily'))
          .height(66).aspectRatio(1)
          .shadow(ShadowStyle.OUTER_DEFAULT_SM)
      }
      Text() {
        Span(`${DateUtil.getNowMonth()} 月 ${DateUtil.getNowDay()} 日`).fontWeight(FontWeight.Bold).fontSize(24)
        Span(' | ').fontWeight(FontWeight.Medium) .fontSize(24)
        Span('为你推荐').fontSize(18).fontColor($r('sys.color.font_secondary'))
      }
    }
    .width('100%')
    .padding({ left: 20, right: 20, bottom: 20 })
  }

  @Builder StackedAlbum() {
    Stack({alignContent: Alignment.Center}) {
      Image(this.list[2].picUrl+"?param=512x512")
        .width(240 - 48).aspectRatio(1)
        .shadow(ShadowStyle.OUTER_DEFAULT_LG)
        .margin({left: 72+24})
        .borderRadius(12)
      Image(this.list[1].picUrl+"?param=512x512")
        .height(240 - 24).aspectRatio(1)
        .shadow(ShadowStyle.OUTER_DEFAULT_MD)
        .margin({left: 48})
        .borderRadius(12)
      Image(this.list[0].picUrl+"?param=512x512")
        .height(240).aspectRatio(1)
        .shadow(ShadowStyle.OUTER_DEFAULT_LG)
        .borderRadius(12)
    }.margin(24).width('100%')
  }

  @Builder SwipeItem(song: Song) {
    AddToPlayListButton({ songId: song.id })
  }

}