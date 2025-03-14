import { DialogUtil, EmitterUtil, LogUtil, ToastUtil } from "@pura/harmony-utils"
import { PlayQueue } from "../../common/entities/PlayQueue"
import { playQueue } from "../../common/functions/play/playControl"
import PlayQueueUtils from "../../common/utils/play/PlayQueueUtils"
import { LoopModeButton } from "../buttons/play/LoopModeButton"
import { LazyData } from '@pie/lazy-data';
import { setHeartMode } from "../../api/songApi"
import { StorageConstants } from "../../common/constants/StorageConstants"
import { PlayList } from "../../common/entities/PlayList"
import Constants from "../../common/constants/Constants"
import { EmitterConstants } from "../../common/constants/EmitterConstants"
import { cleanLastPlayInfo } from "../../common/functions/play/playListOp"
import { gAppTheme } from "../../common/utils/theme/ThemeUtils"

/**
 * 播放列表 Sheet
 */
@Component
export struct PlayQueueSheet {
  @StorageProp('PlayQueue') queue: Array<PlayQueue> = []
  @StorageLink('currentQueueIndex') currentQueueIndex: number = 0
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp(StorageConstants.PLAY_MODE) playmode: number = 1
  @StorageProp(StorageConstants.USER_PLAYLISTS) playLists: Array<PlayList> = []
  @StorageProp(StorageConstants.BREAKPOINT) breakpoint: string = 'sm'
  @State isLoading: boolean = false
  @Link isShow: boolean
  @State dataSource: LazyData<PlayQueue> = new LazyData()
  private scroller: Scroller = new Scroller()

  aboutToAppear(): void {
    this.dataSource.setData(this.queue)

    setTimeout(() => {
      this.scrollToCurrent(false)
    }, 100)

    EmitterUtil.onSubscribe(EmitterConstants.EMITTER_REFRESH_PLAYQUEUE, () => {
      this.dataSource.setData(this.queue)
      this.dataSource.notifyDataReload()
    })
  }

  aboutToDisappear(): void {
    EmitterUtil.off(EmitterConstants.EMITTER_REFRESH_PLAYQUEUE, () => {})
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column({ space: 10 }) {
        Row() {
          Row({ space: 15 }) {
            Text() {
              Span('播放列表').fontSize(Constants.FONT_SIZE_TITLE).fontColor(Color.Gray).fontWeight(FontWeight.Bold)
              Span(`  (${this.queue.length})`).fontSize(Constants.FONT_SIZE_COMMON).fontColor(Color.Gray)
            }

            LoopModeButton({ imgWidth: Constants.SIZE_ICON_BUTTON_BAR, btnWidth: Constants.SIZE_ICON_BUTTON_BAR })

            // HeartMode Button
            if(this.queue.length > 0 && this.playmode == 1) {
              Button() {
                Image($r('app.media.ic_heart_filled')).width(Constants.SIZE_ICON_BUTTON_BAR - 5).fillColor($r('app.color.reverse'))
              }
              .backgroundColor(Color.Transparent)
              .onClick(async () => {
                await this.startHeartMode()
              })
            }

            if(this.isLoading) {
              LoadingProgress().width(Constants.SIZE_ICON_BUTTON_BAR)
            }
          }

          Row({ space: 10 }) {
            Button({ type: ButtonType.Circle }) {
              Image($r('app.media.ic_position')).width(Constants.SIZE_ICON_BUTTON_BAR_SMALL).fillColor(Color.Gray)
            }
            .backgroundColor(Color.Transparent)
            .onClick(() => {
              this.scrollToCurrent()
            })

            Button({ type: ButtonType.Circle }) {
              Image($r('app.media.ic_public_delete_filled')).width(Constants.SIZE_ICON_BUTTON_BAR_SMALL).fillColor(Color.Gray)
            }
            .backgroundColor(Color.Transparent)
            .onClick(() => {
              this.cleanPlayQueue()
            })
          }
        }
        .padding({ left: 5, right: 5 })
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        List({ scroller: this.scroller, space: 20 }) {
          LazyForEach(this.dataSource, (item: PlayQueue, index) => {
            ListItem() {
              this.ItemCard(item, index)
            }
            .padding({ left: 5, right: 5 })
            .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.9 })
          }, (item: PlayQueue, index) => item.song.id.toString() + index)

          ListItem().height(px2vp(this.bottomRectHeight))
        }
        .lanes(this.breakpoint == 'sm' ? 1 : 2)
        .divider({ color: Color.Gray, strokeWidth: 0.1 })
        .width('100%')
        .height('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }

      if(this.isLoading) {
        Column() {

        }
        .justifyContent(FlexAlign.Center)
        .height('100%')
        .width('100%')
      }
    }
    .padding({ left:20, right:20, top:15 })
    .width('100%')
  }

  @Builder ItemCard(item: PlayQueue, index: number) {
    Row({ space: 5 }) {
      Column({ space: 5 }) {
        Text(`${item.song.name}`)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.currentQueueIndex == index ? gAppTheme.colors?.brand : $r('app.color.reverse'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .textAlign(TextAlign.Start)
        Row({ space: 5 }) {
          if(item.playmode == 0) {
            Image($r('app.media.ic_public_todo')).width(14).fillColor(Color.Green)
          } else if(item.song.fee == 1) {
            Text(' VIP ')
              .fontColor('#ffff3232')
              .fontSize(10)
              .padding(2)
              .backgroundColor('#ffffd2d2')
              .borderRadius(5)
          }
          Text(`${item.artists}`)
            .fontSize(12)
            .fontColor(this.currentQueueIndex == index ? gAppTheme.colors?.brand : Color.Gray)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
            .textAlign(TextAlign.Start)
        }
      }
      .layoutWeight(1)
      .onClick(async () => {
        if(this.currentQueueIndex != index) {
          this.isLoading = true
          await playQueue(index)
          this.isShow = false
          this.isLoading = false
        } else return
      })

      // 从播放列表中删除
      if(this.currentQueueIndex != index) {
        Button({ type: ButtonType.Circle }) {
          Image($r('app.media.ic_public_cancel')).width(20).fillColor(Color.Gray)
        }
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          cleanLastPlayInfo()
          PlayQueueUtils.queueDelete(index)
          this.dataSource.deleteData(index)
          this.dataSource.notifyDataReload()
        })
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceAround)
    .padding({ top: 2, bottom: 2 })
  }

  private scrollToCurrent(animation: boolean = true) {
    this.scroller.scrollToIndex(this.currentQueueIndex, animation, ScrollAlign.START)
  }

  private cleanPlayQueue() {
    DialogUtil.showPrimaryDialog({
      title: '确认',
      message: `清空播放列表`,
      primaryButton: "取消",
      secondaryButton: {
        value: '确认',
        fontColor: Color.Red,
        action: async () => {
          try {
            cleanLastPlayInfo()
            PlayQueueUtils.cleanQueue()
            this.dataSource.setData([])
            this.dataSource.notifyDataReload()
          } catch (e) {
            ToastUtil.showToast('清空播放列表时出错')
          }
        }
      }
    })
  }

  private async startHeartMode() {
    DialogUtil.showPrimaryDialog({
      title: '心动歌单',
      message: '是否将播放列表替换为【心动歌单】?\n\n开启心动歌单后，\n将会替换当前播放列表并开始新的播放',
      primaryButton: "取消",
      secondaryButton: {
        value: '确认',
        fontColor: Color.Red,
        action: async () => {
          this.isLoading = true
          try {
            await setHeartMode(this.queue[this.currentQueueIndex].song.id, this.playLists[0].id)
            playQueue(0)
            this.scroller.scrollToIndex(0)
          } catch (e) {
            ToastUtil.showToast('获取心动歌单失败')
            LogUtil.error('获取心动歌单失败: ' + e.message)
          } finally {
            this.dataSource.setData(this.queue)
            this.dataSource.notifyDataReload()
            this.isLoading = false
          }
        }
      }
    })
  }
}