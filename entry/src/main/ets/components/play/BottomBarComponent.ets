import { Song, SongClass } from "../../common/entities/SongsResult"
import { pauseMusic, playNext, playPre, playQueue, resumeMusic } from "../../common/functions/play/playControl"
import playQueueUtils from "../../common/utils/play/PlayQueueUtils"
import { PlayQueueButton } from "../buttons/play/PlayQueueButton"
import { PlayingCover } from "../sheets/PlayingCover"
import { StorageConstants } from "../../common/constants/StorageConstants"
import Constants from "../../common/constants/Constants"
import { curves } from "@kit.ArkUI"
import { gAppTheme } from "../../common/utils/theme/ThemeUtils"

/**
 * 底部播控组件
 */
@Component
export struct BottomBarComponent {
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageLink(StorageConstants.IS_PLAYING) isPlaying: boolean = false
  @StorageProp(StorageConstants.PLAY_MODE) playmode: number = 1
  @StorageProp(StorageConstants.PLAY_FILE_NAME) fileName: string = ''
  @StorageProp(StorageConstants.PLAY_SONG) song: Song = SongClass
  @StorageProp(StorageConstants.PLAY_ARTISTS) artists: string = ''
  @StorageProp(StorageConstants.IS_PAUSED) isPaused: boolean = true
  @StorageProp(StorageConstants.PIC_URL) picUrl: string = ''
  @StorageProp(StorageConstants.PLAY_TIME) time: number = 0
  @StorageProp('player-currentLyric') currentLyric: string = ''
  @State isShow: boolean = false
  @Consume('pageInfos') pageInfos: NavPathStack

  build() {
    Row() {
      if(this.playmode == 0) { Image($r('app.media.ic_public_music')).fillColor($r('app.color.reverse')).songImg() }
      else { Image(this.picUrl + '?param=512y512').songImg() }

      Column({ space: 2 }) {
        Text(this.song.name).textStyle(16).fontWeight(FontWeight.Medium).textOverflow({ overflow: TextOverflow.MARQUEE })
        if(!this.currentLyric || this.currentLyric === '暂无歌词') {
          Text(this.artists).textStyle(12).textOverflow({ overflow: TextOverflow.MARQUEE }).layoutWeight(1).fontColor(Color.Gray)
        }
        else {
          Text(this.currentLyric).textStyle(12).textOverflow({ overflow: TextOverflow.MARQUEE }).layoutWeight(1).fontColor(Color.Gray)
        }
      }
      .padding({ top: 4, bottom: 4 })
      .layoutWeight(1)

      ControlButtons({ isPaused: this.isPaused, isPlaying: this.isPlaying })
        .padding({ right: 5 })
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .borderRadius(Constants.RADIUS_CARD)
    .shadow(ShadowStyle.OUTER_DEFAULT_SM)
    .backgroundColor($r('app.color.bottom_bar_bg'))
    .backgroundBlurStyle(BlurStyle.Thin)
    .height(Constants.HEIGHT_MINI)
    .padding(8)
    .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.9 })
    .onClick(async () => {
      if(!this.isPlaying) {
        await playQueue(playQueueUtils.currentQueueIndex)
      }
      this.isShow = true
    })
    .bindContentCover($$this.isShow, this.Cover(), {
      modalTransition: ModalTransition.DEFAULT,
      transition: TransitionEffect.move(TransitionEdge.BOTTOM).animation({
        curve: curves.springMotion(0.5)
      }),
      backgroundColor: Color.Black
    })
  }

  @Builder
  Cover() {
    PlayingCover({ isShow: this.isShow })
      .height('105%')
  }
}

@Component
struct ControlButtons {
  @Link isPaused: boolean
  @Link isPlaying: boolean
  build() {
    Row({ space: 10 }) {
      // Last
      Image($r('app.media.ic_public_play_last')).buttonImgStyle()
        .fillColor(gAppTheme.colors?.brand)
        .onClick(() => {
          playPre()
        })

      // Play & Pause
      if (!this.isPaused) {
        Image($r('app.media.ic_public_pause_norm')).buttonImgStyle()
          .fillColor(gAppTheme.colors?.brand)
          .onClick(() => {
            pauseMusic()
          })
      } else {
        Image($r('app.media.ic_public_play_norm')).buttonImgStyle()
          .fillColor(gAppTheme.colors?.brand)
          .onClick(() => {
          if(!this.isPlaying) playQueue(playQueueUtils.currentQueueIndex)
          else resumeMusic()
        })
      }

      // Next
      Image($r('app.media.ic_public_play_next')).buttonImgStyle()
        .fillColor(gAppTheme.colors?.brand)
        .onClick(() => {
          playNext()
        })

      PlayQueueButton({ imgWidth: 25, imgColor: gAppTheme.colors?.brand })
    }
  }
}

@Extend(Image) function buttonImgStyle() {
  .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.6 })
  .aspectRatio(1)
  .width(30)
  .fillColor($r('app.color.reverse'))
  .draggable(false)
}

@Extend(Text) function textStyle(size:number) {
  .fontSize(size)
  .fontColor($r('app.color.reverse'))
  .textAlign(TextAlign.Start)
  .layoutWeight(1)
  .width('100%')
  .maxLines(1)
  .padding({ left: 10, right: 10 })
  .textOverflow({ overflow: TextOverflow.Ellipsis })
}

@Extend(Image) function songImg() {
  .height(Constants.HEIGHT_MINI)
  .aspectRatio(1)
  .borderRadius(10)
  .padding(1)
}
