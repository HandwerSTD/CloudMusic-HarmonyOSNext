import { DialogUtil, ToastUtil } from "@pura/harmony-utils"
import Constants from "../../common/constants/Constants"
import { StorageConstants } from "../../common/constants/StorageConstants"
import { checkValidUrl } from "../../common/functions/common/get"
import { openInWeb } from "../../common/functions/common/open"
import PreferencesUtils from "../../common/utils/data/PreferencesUtils"

@CustomDialog
export struct ApiDialog {
  @StorageProp(StorageConstants.API_URL) customApiUrl: string = ''
  @StorageProp(StorageConstants.VALID_API_URL) validApiUrl: boolean = false
  controller: CustomDialogController

  build() {
    Column({ space: 20 }) {
      Row({ space: 10 }) {
        Text('API服务器状态\n需要设置API服务器以使用本应用')
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.reverse'))
          .textAlign(TextAlign.Center)
          .lineHeight(30)
      }

      this.Explain()

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

      Button('确认并关闭')
        .onClick(() => {
          this.setCustomApiUrl()
          this.controller.close()
        })
        .margin({ top: 20 })
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .padding({ top: Constants.PADDING_EDGE_TEXT, bottom: Constants.PADDING_EDGE_TEXT })
  }

  @Builder SetApiUrl() {
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

  setCustomApiUrl() {
    AppStorage.setOrCreate(StorageConstants.API_URL,this.customApiUrl)
    PreferencesUtils.putPreferenceValue(StorageConstants.SET_PERF ,StorageConstants.API_URL,this.customApiUrl)
    ToastUtil.showToast('设置成功')
    checkValidUrl()
  }

  @Builder Explain() {
    Button() {
      Row({ space: 5 }) {
        Image($r('app.media.ic_public_help'))
          .fillColor($r('app.color.reverse'))
          .width(15)
          .draggable(false)
        Text('设置说明')
          .fontColor($r('app.color.reverse'))
          .fontSize(12)
      }
    }
    .backgroundColor(Color.Transparent)
    .onClick(() => {
      DialogUtil.showPrimaryDialog({
        title: 'API服务器地址',
        message: '你需要填入API服务器地址才可以正常使用本应用\n' +
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