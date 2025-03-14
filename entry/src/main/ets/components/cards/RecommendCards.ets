import { getDailySongs, setHeartMode } from "../../api/songApi"
import Constants from "../../common/constants/Constants"
import { StorageConstants } from "../../common/constants/StorageConstants"
import { PlayList } from "../../common/entities/PlayList"
import { playQueue } from "../../common/functions/play/playControl"
import PlayQueueUtils from "../../common/utils/play/PlayQueueUtils"
import { promptAction } from "@kit.ArkUI"
import { DateUtil, LogUtil } from "@pura/harmony-utils"
import { DailySongRes } from "../../api/playListApi"


const cardRadius: number = 5
const cardHeight: number = 250
const cardWidth: number = 200

@Component
struct ContentButton {
  @Prop firText:string
  @Prop secText:string
  @Prop imgUrl:ResourceStr
  clickAction: () => void = () => {}
  @Prop showDate: boolean = false

  private dateIcons: Resource[] = []

  aboutToAppear(): void {

  }

  build() {

    Stack({ alignContent: Alignment.Center }) {
      Column() {

        Row({space: 4}) {
          Text(){
            if (this.showDate) {
              SymbolSpan($r(`sys.symbol.calendar_${DateUtil.getTodayStr('dd')}`))
            }
            Span(' ')
            Span(this.firText)
          }
            .width('100%')
            .textStyle(Constants.FONT_SIZE_TITLE + 3, true)
            .padding(Constants.PADDING_EDGE_DEFAULT)
            .textShadow({ radius: 15 })
        }
        Text(`${this.secText}`)
          .width('100%')
          .textStyle(Constants.FONT_SIZE_COMMON - 3)
          .textAlign(TextAlign.Center)
          .backgroundColor(Color.Transparent)
          .textShadow({ radius: 5 })
          .borderRadius({ bottomLeft: 14, bottomRight: 14 })
          .height(Constants.FONT_SIZE_COMMON * 2)
          .backdropBlur(100)
      }
      .width(cardWidth - 20)
      .height(cardHeight - 20)
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundImage(this.imgUrl)
      .backgroundImageSize(ImageSize.Cover)
      .borderRadius(14)
      .shadow({ radius: 16, type: ShadowType.BLUR, offsetY: 10 })

    }
    .backgroundColor(Color.Transparent)
    .width(cardWidth)
    .height(cardHeight)
    .onClick(() => {
      this.clickAction()
    })
    .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.9 })
  }
}

@Component
export struct RecommendCards {
  @Consume('pageInfos') pageInfos: NavPathStack
  @StorageProp(StorageConstants.USER_PLAYLISTS) playLists: Array<PlayList> = []
  @Prop isLogged: boolean
  @State isLoadingHeart: boolean = false
  @State dailySongCover: ResourceStr = $r('app.media.bg_daily')


  async loadDailySongCover(): Promise<void> {
    try {
      let result:Array<DailySongRes> = await getDailySongs()
      // if(result.length < 3) { result = await getDailySongs(false) }
      this.dailySongCover = result[0].picUrl + "?param=256y256"
      LogUtil.debug(`loadDailySongCover, result = ${this.dailySongCover}`)
    } catch (e) {
      LogUtil.error('Error fetching songs: ', e)
    } finally {

    }
  }

  aboutToAppear(): void {
    setTimeout(() => {
      this.loadDailySongCover()
    }, 300)
  }

  build() {
    List() {
      ListItem().width(10)
      /**
       * 每日推荐卡片
       */
      ListItem() {
        ContentButton({
          firText: `每日推荐`,secText:'符合你口味的新鲜好歌',
          clickAction: () => {
          if(this.pageInfos.size() == 0) {
          this.pageInfos.pushPathByName('DailyListPage', null)
        } else {
          this.pageInfos.replacePathByName('DailyListPage', null)
        }
        }, showDate: true,
          imgUrl: (this.dailySongCover)
        })
      }

      /**
       * 音乐云盘卡片
       */
      ListItem() {
        ContentButton({
          firText: `音乐云盘`,secText:`随时随地畅听`,
          clickAction: () => {
            if(this.isLogged) {
              if(this.pageInfos.size() == 0) {
                this.pageInfos.pushPathByName('CloudPage', null)
              } else {
                this.pageInfos.replacePathByName('CloudPage', null)
              }
            } else {
              promptAction.showToast({ message: '请登录后再试' })
            }
          }, showDate: false,
          imgUrl: $r('app.media.bg_cloud')
        })
      }

      /**
       * 心动歌单卡片
       */
      ListItem() {
        ContentButton({
          firText:`心动歌单`, secText: `智能播放`, imgUrl: $r('app.media.bg_heart'),
          clickAction: async () => {
            if(this.isLogged) {
              if(!this.isLoadingHeart) {
                try {
                  this.isLoadingHeart = true
                  promptAction.showToast({ message: '开始播放心动歌单' })
                  await setHeartMode(PlayQueueUtils.getCurrentSong().id, this.playLists[0].id)
                  playQueue(0)
                } catch (e) {
                  promptAction.showToast({ message: '获取心动歌单失败: ' + e.message })
                } finally {
                  this.isLoadingHeart = false
                }
              } else {
                promptAction.showToast({ message: '正在加载, 请稍后' })
              }
            } else {
              promptAction.showToast({ message: '请登录后再试' })
            }
          }
        })
      }

      ListItem().width(5)
    }
    .borderRadius(0)
    .scrollBar(BarState.Off)
    .listDirection(Axis.Horizontal)
    .width('100%')
  }
}

@Extend(Button) function buttonSty() {
  .type(ButtonType.Normal)
  .width('100%')
  .borderRadius(cardRadius)
  .backgroundColor(Color.Transparent)
}

@Extend(Text) function textStyle(size: number, isBold: boolean = false) {
  .fontSize(size)
  .fontColor(Color.White)
  .fontWeight(isBold ? FontWeight.Bold : FontWeight.Normal)
}

/**
 * RecommendCards
 * Loading
 * Skeleton
 */
@Component
export struct RecommendCards_Skeleton {
  build() {
    List({ space: 15 }) {
      ListItem().width(5)
      ListItem() {
        this.ContentSkeleton()
      }
      .width(cardWidth)
      ListItem() {
        this.ContentSkeleton()
      }
      .width(cardWidth)
      ListItem() {
        this.ContentSkeleton()
      }
      .width(cardWidth)

      ListItem().width(5)
    }
    .borderRadius(0)
    .scrollBar(BarState.Off)
    .listDirection(Axis.Horizontal)
    .width('100%')
  }

  @Builder ContentSkeleton() {
    Button() {
      Column() {
        Column()
          .backgroundColor($r('sys.color.background_secondary'))
          .alignSelf(ItemAlign.Start)
          .width('70%')
          .borderRadius(cardRadius)
          .height(Constants.FONT_SIZE_TITLE)
          .padding(Constants.PADDING_EDGE_DEFAULT)
        Column({ space: 3 }) {
          Column()
            .backgroundColor($r('sys.color.background_secondary'))
            .alignSelf(ItemAlign.Center)
            .width('80%')
            .borderRadius(cardRadius)
            .height(Constants.FONT_SIZE_BAR - 2)
            .padding(Constants.PADDING_EDGE_DEFAULT)
          Column()
            .backgroundColor($r('sys.color.background_secondary'))
            .alignSelf(ItemAlign.Center)
            .width('80%')
            .borderRadius(cardRadius)
            .height(Constants.FONT_SIZE_BAR - 2)
            .padding(Constants.PADDING_EDGE_DEFAULT)
        }
      }
      .padding(Constants.PADDING_EDGE_DEFAULT)
      .justifyContent(FlexAlign.SpaceBetween)
      .height('100%')
      .width('100%')
    }
    .buttonSty()
    .backgroundColor($r('app.color.main'))
    .width(cardWidth)
    .height(cardHeight)
  }
}