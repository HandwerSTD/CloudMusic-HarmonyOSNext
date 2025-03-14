import { DialogUtil, PasteboardUtil, ToastUtil } from "@pura/harmony-utils"
import Constants from "../../common/constants/Constants"
import { StorageConstants } from "../../common/constants/StorageConstants"
import { checkValidUrl } from "../../common/functions/common/get"
import { openInWeb } from "../../common/functions/common/open"
import PreferencesUtils from "../../common/utils/data/PreferencesUtils"
import { ExplainButton } from "../buttons/ExplainButton"
import { promptAction } from "@kit.ArkUI"

/**
 * 自定义API服务器地址
 * Sheet
 */
@Component
export struct SetApiSheet {
  @StorageLink(StorageConstants.IS_CUSTOM_COOKIE) isCustomCookie: boolean = false
  @StorageProp(StorageConstants.CUSTOM_COOKIE) customCookie: string = ''
  @StorageProp(StorageConstants.COOKIE) logonCookie: string = ''
  @StorageProp(StorageConstants.API_URL) customApiUrl: string = ''
  @StorageProp(StorageConstants.VALID_API_URL) validApiUrl: boolean = false
  @StorageProp(StorageConstants.BREAKPOINT) breakpoint: string = 'sm'
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @Link isShowSheet: boolean

  build() {
    Column({ space: 20 }) {
      Text('设置')
        .width('100%')
        .fontSize(Constants.FONT_SIZE_TITLE)
        .fontWeight(FontWeight.Bold)
        .padding({ top: this.breakpoint === 'sm' ? Constants.PADDING_EDGE_DEFAULT : Constants.PADDING_EDGE_TEXT,
          left: Constants.PADDING_EDGE_TEXT,
          right: Constants.PADDING_EDGE_TEXT
        })

      this.SetApiUrl()
      Text() {
        Span(`当前API服务器状态: `)
        Span(`${this.validApiUrl ? '可用' : '不可用'}`)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .textAlign(TextAlign.Center)
      .fontColor($r('app.color.reverse'))
      .fontSize(Constants.FONT_SIZE_COMMON)
      .padding({ bottom: 30 })

      this.SetCookie()
    }
    .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT, bottom: px2vp(this.bottomRectHeight) + Constants.PADDING_EDGE_TEXT })
    .width('100%')
    .constraintSize({
      minWidth: 200,
      maxWidth: 600
    })
  }

  @Builder SetApiUrl() {
    Column({ space: 10 }) {
      Row() {
        Row({ space: 5 }) {
          Text('API服务器地址').LeftText()
          Button() {
            Image($r('app.media.ic_public_help'))
              .fillColor($r('app.color.reverse'))
              .width(15)
              .draggable(false)
          }
          .type(ButtonType.Circle)
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            DialogUtil.showPrimaryDialog({
              title: 'API服务器地址',
              message: '你需要填入API服务器地址才可以正常使用本软件\n' +
                '需要自行搭建NeteaseCloudMusicApi服务\n\n' +
                '地址格式: http://example.com:3000\n' +
                '(注意末尾不带\"/\")\n\n' +
                '填入后重启应用生效',
              primaryButton: {
                value: '使用文档',
                action: () => { openInWeb('https://docs.chenlvin.cc/cloudmusic/#/help?timestamp=' + new Date().getTime()) }
              },
              secondaryButton: '确认'
            })
          })
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ left: Constants.PADDING_EDGE_TEXT, right: Constants.PADDING_EDGE_TEXT })

      Column({ space: 10 }) {
        Row({ space: 10 }) {
          TextInput({ text: this.customApiUrl })
            .layoutWeight(4)
            .onChange((text) => this.customApiUrl = text)
            .borderRadius(Constants.RADIUS_IMG)
          Button('设置')
            .backgroundColor($r('app.color.app_red'))
            .layoutWeight(1)
            .onClick(() => {
              this.setCustomApiUrl()
            })
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')
        .padding({ left: Constants.PADDING_EDGE_TEXT, right: Constants.PADDING_EDGE_TEXT })
      }
      .width('100%')
    }
  }

  @Builder SetCookie() {
    Column({ space: 10 }) {

      if (this.logonCookie !== '') {
        Button('提取已登录 Cookie')
          .width('100%')
          .onClick(() => {
            PasteboardUtil.setDataText(this.logonCookie)
            promptAction.showToast({
              message: '已复制到剪贴板'
            })
          })
      }

      Row() {
        Row({ space: 5 }) {
          Text('手动设置Cookie').LeftText()
          ExplainButton({ title: '手动设置Cookie',
            msg: '设置后每次API请求都将使用该Cookie, 包括登录、用户信息等获取, 重启后生效\n\n' +
              'Cookie只需要其中key为MUSIC_U的数据即可\n' +
              '例如: MUSIC_U=XXXXX'
          })
        }
        Toggle({ type: ToggleType.Switch, isOn: this.isCustomCookie })
          .height(24)
          .width(48)
          .selectedColor($r('app.color.app_red'))
          .onChange((isOn) => {
            animateTo({ duration: 100, curve: Curve.EaseInOut }, () => {
              this.toggleCustomCookie(isOn)
            })
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ left: Constants.PADDING_EDGE_TEXT, right: Constants.PADDING_EDGE_TEXT })

      if(this.isCustomCookie) {
        Column({ space: 10 }) {
          TextArea({ text: this.customCookie })
            .width('100%')
            .onChange((text) => this.customCookie = text)
            .borderRadius(Constants.RADIUS_IMG)
            .height(150)
            .textAlign(TextAlign.Start)
          Button('设置')
            .backgroundColor($r('app.color.app_red'))
            .width(100)
            .onClick(() => {
              this.setCustomCookie()
            })
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')
        .padding({ left: Constants.PADDING_EDGE_TEXT, right: Constants.PADDING_EDGE_TEXT })
      }
    }
  }

  toggleCustomCookie(isOn: boolean) {
    this.isCustomCookie = isOn
    AppStorage.setOrCreate(StorageConstants.IS_CUSTOM_COOKIE, this.isCustomCookie)
    PreferencesUtils.putPreferenceValue(StorageConstants.SET_PERF, StorageConstants.IS_CUSTOM_COOKIE, this.isCustomCookie)
  }

  setCustomApiUrl() {
    AppStorage.setOrCreate(StorageConstants.API_URL,this.customApiUrl)
    PreferencesUtils.putPreferenceValue(StorageConstants.SET_PERF ,StorageConstants.API_URL,this.customApiUrl)
    ToastUtil.showToast('设置成功')
    checkValidUrl()
  }

  setCustomCookie() {
    let cookie = this.customCookie.trim()
    if (!cookie.endsWith('; OS=pc')) {
      cookie += '; OS=pc'
    }
    AppStorage.setOrCreate(StorageConstants.CUSTOM_COOKIE, cookie)
    PreferencesUtils.putPreferenceValue(StorageConstants.SET_PERF ,StorageConstants.CUSTOM_COOKIE, cookie)
    ToastUtil.showToast('设置成功')
  }
}

@Extend(Text) function LeftText() {
  .fontSize(18)
  .fontWeight(FontWeight.Bold)
}