import { Song, SongClass } from "../../common/entities/SongsResult"
import { changeDuration } from "../../common/functions/common/convert"
import { pauseMusic, playNext, playPre, resumeMusic, seekMusic } from "../../common/functions/play/playControl"
import { AddToPlayListCircleButton } from "../buttons/play/AddToPlayListButton"
import { LoopModeButton } from "../buttons/play/LoopModeButton"
import { PlayQueueButton } from "../buttons/play/PlayQueueButton"
import { DownloadDialog } from "../dialog/DownloadDialog"
import { LyricComponent } from "../play/LyricComponent"
import { AVCastPicker } from "@kit.AVSessionKit"
import { TimerButton } from "../buttons/play/TimerButton"
import { StorageConstants } from "../../common/constants/StorageConstants"
import Constants from "../../common/constants/Constants"
import { PasteboardUtil, ToastUtil } from "@pura/harmony-utils"
import { PlayerActionSheet } from "./PlayerActionSheet"
import { likeThisSong } from "../../common/functions/play/songLike"
import { curves } from "@kit.ArkUI"

@Component
export struct PlayingCover {
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp(StorageConstants.PLAY_MODE) playmode: number = 1
  @StorageProp(StorageConstants.PLAY_SONG) song: Song = SongClass
  @StorageProp(StorageConstants.PLAY_ARTISTS) artists: string = ''
  @StorageProp(StorageConstants.IS_PAUSED) isPaused: boolean = false
  @StorageProp(StorageConstants.PIC_URL) picUrl: string = ''
  @StorageProp(StorageConstants.PLAY_TIME) time: number = 0
  @StorageProp(StorageConstants.ISLIKED) isLiked: boolean = false
  @StorageProp(StorageConstants.PLAY_COUNTDOWN_WORKING) isTimerWorking: boolean = false
  @StorageProp(StorageConstants.PLAY_IS_LOCALFILE) isLocalFile: boolean = false
  @StorageProp(StorageConstants.BREAKPOINT) breakpoint: string = 'sm'
  @Link isShow: boolean
  @State sliderThickness: number = 10
  @State isMovingSlider: boolean = false
  @State sliderMovingTime: number = 0
  @State tabPageIndex: number = 0
  @State isShowMenu: boolean = false
  @State isShowTimer: boolean = false
  @State isShowAddSheet: boolean = false
  @State isLikeProcessing: boolean = false
  @State totalOpacity: number = 0
  private dialogController: CustomDialogController = new CustomDialogController({
    builder: DownloadDialog({
      song: this.song,
      picUrl: this.picUrl,
      artists: this.artists,
      duration: changeDuration(this.song.duration)
    }),
  })
  private phoneUISwiperController: SwiperController = new SwiperController()

  aboutToAppear(): void {
    setTimeout(() => {
      animateTo({ duration: 300, curve: Curve.EaseInOut }, () => {
        this.totalOpacity = 0.7
      })
    }, 700)
  }

  build() {
   Stack() {
     // Background
     Stack() {
       Image(this.playmode == 1 ? this.picUrl + '?param=512y512' : $r('app.media.bg_default'))
         .blur(100)
         .width('100%')
         .height('100%')
         .animation({
           duration: 300,
           curve: Curve.Linear
         })
         .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
       Column()
         .width('100%')
         .height('100%')
         .opacity(0.6)
         .backgroundColor(Color.Black)
         .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
     }
     .width('100%')
     .height('100%')

     /**
      * 主内容
      */
     if(this.breakpoint == 'sm') {
       this.PhoneUI()
     } else {
       this.LargeUI()
     }

     /**
      * Head栏
      */
     this.Head()

   }
   .height('100%')
   .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  /**
   * 功能栏
   */
  @Builder
  ToolBar() {
    if(this.tabPageIndex == 0) {
      Row() {
        /**
         * Clock-Timer
         */
        TimerButton({ isTimerWorking: this.isTimerWorking, isShow: this.isShowTimer })
          .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.7 })
        if (this.playmode == 1) {
          /**
           * Download
           */
          Image($r('app.media.ic_arrow_down_o_icon'))
            .fillColor(Color.White)
            .height(25)
            .aspectRatio(1)
            .draggable(false)
            .backgroundColor(Color.Transparent)
            .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.7 })
            .onClick(() => {
              this.dialogController.open()
            })

          /**
           * AddToPlayList
           */
          AddToPlayListCircleButton({
            song: this.song,
            imgColor: Color.White,
            imgHeight: 29,
            isShowAddSheet: this.isShowAddSheet
          })
            .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.7 })

          /**
           * Heart
           */
          Image(this.isLiked ? $r('app.media.ic_public_favor_filled') : $r('app.media.ic_public_favor'))
            .fillColor(Color.White)
            .height(25)
            .aspectRatio(1)
            .draggable(false)
            .backgroundColor(Color.Transparent)
            .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.7 })
            .onClick(async () => {
              if(this.isLikeProcessing) return
              this.isLikeProcessing = true
              try {
                await likeThisSong()
              } finally {
                this.isLikeProcessing = false
              }
            })
        }

        /**
         * More
         */
        Image($r('app.media.ic_more_vertical_o_icon'))
          .fillColor(Color.White)
          .height(23)
          .aspectRatio(1)
          .draggable(false)
          .backgroundColor(Color.Transparent)
          .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.7 })
          .bindSheet(this.isShowMenu, this.MenuSheet(), {
            backgroundColor: Color.Transparent,
            showClose: true,
            height: SheetSize.MEDIUM,
            dragBar: false,
            blurStyle: BlurStyle.Regular,
            preferType: SheetType.CENTER,
            onDisappear: () => {
              this.isShowMenu = false
            }
          })
          .onClick(() => {
            this.isShowMenu = true
          })
      }
      .justifyContent(FlexAlign.SpaceEvenly)
      .width('100%')
      .height(30)
      .opacity(0.6)
    }
  }

  /**
   * 进度条组件
   */
  @Builder
  SliderContent() {
    Column({ space: 5 }) {
      Row() {
        // 当前时间
        Text(`${changeDuration(this.time)}`)
          .fontSize(Constants.FONT_SIZE_COMMON)
          .layoutWeight(1)
          .textAlign(TextAlign.Start)
          .fontColor(Color.White)
          .opacity(this.tabPageIndex == 0 ? 0.7 : 0.1)

        // 拖动进度条时，显示即将跳转的时间
        if (this.isMovingSlider) {
          Column() {
            Text(`${changeDuration(this.sliderMovingTime)}`)
              .fontColor(Color.White)
              .backgroundColor(Color.Gray)
              .borderRadius(15)
              .fontSize(Constants.FONT_SIZE_COMMON)
              .textAlign(TextAlign.Center)
              .padding({ left: 10, right: 10 })
          }
          .layoutWeight(1)
        }

        // 总时间
        Text(`${changeDuration(this.song.duration)}`)
          .fontSize(Constants.FONT_SIZE_COMMON)
          .layoutWeight(1)
          .textAlign(TextAlign.End)
          .fontColor(Color.White)
          .opacity(this.tabPageIndex == 0 ? 0.7 : 0.1)
      }
      .width('90%')
      .justifyContent(FlexAlign.SpaceAround)

      // 进度条
      Slider({
        value: this.time,
        max: this.song.duration,
        style: SliderStyle.InSet
      })
        .width('90%')
        .blockColor(Color.White)
        .trackColor(Color.Gray)
        .trackThickness(this.sliderThickness)
        .selectedColor(Color.White)
        .showSteps(false)
        .showTips(false)
        .opacity(this.tabPageIndex == 0 ? 0.7 : 0.1)
        .animation({
          duration: 600,
          curve: Curve.LinearOutSlowIn,
        })
        .onChange((value: number, mode: SliderChangeMode) => {
          if (mode == SliderChangeMode.Begin) {
            this.isMovingSlider = true
            this.sliderThickness = 20
          } else if (mode == SliderChangeMode.Moving) {
            this.sliderMovingTime = value
          } else if (mode == SliderChangeMode.End) {
            this.time = value
            this.isMovingSlider = false
            this.sliderThickness = 10
            seekMusic(value)
          }
        })
    }
  }

  /**
   * PlayButton
   * 控制上一首、下一首、播放和暂停
   */
  @Builder
  PlayButton() {
    // 上一首
    Image($r('app.media.ic_public_play_last')).buttonImgStyle()
    .onClick(() => {
      playPre()
    })

    // 暂停、继续
    Image(!this.isPaused ? $r('app.media.ic_public_pause') : $r('app.media.ic_play_fill')).buttonImgStyle()
      .onClick(() => {
        if(this.isPaused) {
          resumeMusic()
        } else {
          pauseMusic()
        }
      })

    // 下一首
    Image($r('app.media.ic_public_play_next')).buttonImgStyle()
    .onClick(() => {
      playNext()
    })
  }

  /**
   * Head
   */
  @Builder
  Head() {
    Row() {
      Button({ type: ButtonType.Circle }) { Image($r('app.media.ic_public_arrow_down_0')).draggable(false).fillColor(Color.White).width(Constants.SIZE_ICON_BUTTON_COMMON).aspectRatio(1) }
      .backgroundColor(Color.Transparent)
      .onClick(() => { this.isShow = false })

      /**
       * AVCastPicker
       */
      Column() {
        AVCastPicker({
          normalColor: Color.White,
          sessionType: 'audio'
        })
          .width(23)
          .height(23)
          .backgroundColor(Color.Transparent)
      }
    }
    .position({ top: 0 })
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ top: px2vp(this.topRectHeight), left: 12, right: 16, bottom: 5 })
    // 手动平移 平衡视觉重心
    .opacity(this.totalOpacity)
  }

  /**
   * Information
   */
  @Builder
  SongInfo() {
    Column({ space: 20 }) {
      // 歌曲封面图片
      if (this.playmode == 0) {
        Stack() {
          Column() {
          }
          .height('60%')
          .borderRadius(5)
          .aspectRatio(1)
          Image($r('app.media.ic_public_music'))
            .height('30%').fillColor(Color.Gray)
            .borderRadius(5)
            .aspectRatio(1)
        }
        .padding({ bottom: 30 })
      } else {
        Stack() {
          LoadingProgress().width(60)
          if(this.picUrl != '') {
            Image(this.picUrl + '?param=512y512')
              .height('60%')
              .borderRadius(5)
              .aspectRatio(1)
              .shadow({ radius: 30, type: ShadowType.BLUR, offsetX: 20, offsetY: 20 })
              .onClick(() => {
                if (this.breakpoint == 'sm') {
                  this.phoneUISwiperController.changeIndex(1, true)
                }
              })
          }
          else {
            Column()
            .height('60%')
            .borderRadius(5)
            .aspectRatio(1)
          }
        }
        .padding({ bottom: 30 })
      }

      // 歌曲名称&艺术家
      Text(this.song.name)
        .textStyle(24)
        .fontWeight(FontWeight.Bold)
        .onClick(() => {
          PasteboardUtil.setDataText(this.song.name)
          ToastUtil.showToast('已复制歌名到剪贴板', { duration: 3000 })
        })
      Text(this.artists)
        .textStyle(16)
        .onClick(() => {
          PasteboardUtil.setDataText(this.artists)
          ToastUtil.showToast('已复制歌手名到剪贴板', { duration: 3000 })
        })
    }
    .layoutWeight(1)
    .width('100%')
    .padding({ left: 15, right: 15, top:px2vp(this.topRectHeight) + 40 })
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .gesture(
      SwipeGesture({
        fingers: 1,
        direction: SwipeDirection.Vertical
      }).onAction(() => { this.isShow = false })
    )
  }

  @Builder PhoneUI() {
    Column() {
      Swiper(this.phoneUISwiperController) {
        this.SongInfo()
        LyricComponent()
          .padding({ top: px2vp(this.topRectHeight) })
          .width('100%')
      }
      .indicator(
        new DotIndicator()
          .top(px2vp(this.topRectHeight) + 5)
          .selectedColor(Color.White)
          .color(Color.Gray)
      )
      .clip(false)
      .loop(false)
      .layoutWeight(1)
      .onAnimationStart((from, target) => {
        animateTo({ curve: curves.springMotion(0.50, 0.75) }, () => {
          this.tabPageIndex = target
        })
      })

      Column({ space: 10 }) {
        this.SliderContent()
        this.ToolBar()
        Row() {
          LoopModeButton({ imgColor: Color.White }).opacity(0.8)
          this.PlayButton()
          PlayQueueButton({ imgColor: Color.White }).opacity(0.8)
        }
        .opacity(this.tabPageIndex == 0 ? 0.8 : 0.2)
        .padding({ top: 20, bottom: 15 })
        .justifyContent(FlexAlign.SpaceEvenly)
        .width('100%')

        if(this.tabPageIndex == 0) {
          Row({ space: 15 }) {
            if(this.isLocalFile) { Text('本地文件播放中').fontSize(10).fontColor(Color.Gray) }
            if(this.isTimerWorking) { Text('已设置定时关闭').fontSize(10).fontColor(Color.Gray) }
          }
          .justifyContent(FlexAlign.Center)
          .width('100%')
          .height(30)
          .backgroundColor(Color.Transparent)
        }
      }
      .constraintSize({
        minWidth: 200,
        maxWidth: 500
      })
      .width('100%')
    }.padding({bottom: 36}) // 外层高度 105%，内层抬高补偿一点
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder LargeUI() {
    Row() {
      Column() {
        this.SongInfo()
        Column({ space: 10 }) {
          this.SliderContent()
          this.ToolBar()
          Row() {
            LoopModeButton({ imgColor: Color.White }).opacity(0.8)
            this.PlayButton()
            PlayQueueButton({ imgColor: Color.White }).opacity(0.8)
          }
          .opacity(this.tabPageIndex == 0 ? 0.8 : 0.2)
          .padding({ top: 20, bottom: 15 })
          .justifyContent(FlexAlign.SpaceEvenly)
          .width('90%')
          Row({ space: 15 }) {
            if(this.isLocalFile) { Text('本地文件播放中').fontSize(10).fontColor(Color.Gray) }
            if(this.isTimerWorking) { Text('已设置定时关闭').fontSize(10).fontColor(Color.Gray) }
          }
          .justifyContent(FlexAlign.Center)
          .width('100%')
          .height(30)
          .backgroundColor(Color.Transparent)
        }
        .width('100%')
      }
      .layoutWeight(0.9)

      LyricComponent()
        .width('100%')
        .layoutWeight(1.1)
    }
    .width('100%')
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder MenuSheet() {
    PlayerActionSheet({ isShow: this.isShowMenu, isShowTimer: this.isShowTimer, isShowAddSheet: this.isShowAddSheet })
  }
}

@Extend(Text) function textStyle(size:number) {
  .fontSize(size)
  .fontColor(Color.White)
  .maxLines(1)
  .padding({ left:20, right:20 })
  .textOverflow({ overflow: TextOverflow.MARQUEE })
}

@Extend(Image) function buttonImgStyle() {
  .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.8 })
  .width(44)
  .fillColor(Color.White)
  .draggable(false)
}

