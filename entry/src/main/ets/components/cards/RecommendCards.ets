import { setHeartMode } from "../../api/songApi"
import Constants from "../../common/constants/Constants"
import { StorageConstants } from "../../common/constants/StorageConstants"
import { PlayList } from "../../common/entities/PlayList"
import { playQueue } from "../../common/functions/play/playControl"
import PlayQueueUtils from "../../common/utils/play/PlayQueueUtils"
import { promptAction } from "@kit.ArkUI"
import { DateUtil } from "@pura/harmony-utils"


const cardRadius: number = 5
const cardHeight: number = 250
const cardWidth: number = 200

@Builder function ContentButton(firText:string, secText:string, imgUrl:ResourceStr, onClick?: () => void, showDate: boolean = false) {
  Stack({ alignContent: Alignment.Center }) {
    Column() {
      Text(`${firText}`)
        .width('100%')
        .textStyle(Constants.FONT_SIZE_TITLE + 3, true)
        .padding(Constants.PADDING_EDGE_DEFAULT)
        .textShadow({ radius: 15 })
      Text(`${secText}`)
        .width('100%')
        .textStyle(Constants.FONT_SIZE_COMMON - 3)
        .textAlign(TextAlign.Center)
        .backgroundColor(Color.Transparent)
        .textShadow({ radius: 5 })
        .borderRadius({ bottomLeft: cardRadius, bottomRight: cardRadius })
        .height(Constants.FONT_SIZE_COMMON * 2)
        .backdropBlur(100)
    }
    .width(cardWidth - 20)
    .height(cardHeight - 20)
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundImage(imgUrl)
    .backgroundImageSize(ImageSize.Cover)
    .borderRadius(Constants.RADIUS_IMG)
    .shadow({ radius: 10, type: ShadowType.BLUR, offsetX: 10, offsetY: 10 })

    if(showDate) {
      Text(`${DateUtil.getTodayStr('dd')}`)
        .width('100%')
        .fontSize(Constants.FONT_SIZE_TITLE * 2)
        .textShadow({ radius: 5 })
        .fontWeight(FontWeight.Bolder)
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)
        .backgroundColor(Color.Transparent)
    }
  }
  .backgroundColor(Color.Transparent)
  .width(cardWidth)
  .height(cardHeight)
  .onClick(onClick)
  .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.9 })
}

@Component
export struct RecommendCards {
  @Consume('pageInfos') pageInfos: NavPathStack
  @StorageProp(StorageConstants.USER_PLAYLISTS) playLists: Array<PlayList> = []
  @Prop isLogged: boolean
  @State isLoadingHeart: boolean = false

  build() {
    List() {
      ListItem().width(10)
      /**
       * 每日推荐卡片
       */
      ListItem() {
        ContentButton(`每日推荐`,'符合你口味的新鲜好歌',$r('app.media.bg_daily'),() => {
          if(this.pageInfos.size() == 0) {
            this.pageInfos.pushPathByName('DailyListPage', null)
          } else {
            this.pageInfos.replacePathByName('DailyListPage', null)
          }
        }, true)
      }

      /**
       * 音乐云盘卡片
       */
      ListItem() {
        ContentButton(`音乐云盘`,`随时随地畅听`,$r('app.media.bg_cloud'),() => {
          if(this.isLogged) {
            if(this.pageInfos.size() == 0) {
              this.pageInfos.pushPathByName('CloudPage', null)
            } else {
              this.pageInfos.replacePathByName('CloudPage', null)
            }
          } else {
            promptAction.showToast({ message: '请登录后再试' })
          }
        })
      }

      /**
       * 心动歌单卡片
       */
      ListItem() {
        ContentButton(`心动歌单`,`智能播放`,$r('app.media.bg_heart'), async () => {
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