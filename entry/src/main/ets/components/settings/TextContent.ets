import { AppUtil, PasteboardUtil, ToastUtil } from "@pura/harmony-utils"
import { AppConstants } from "../../common/constants/AppConstants"
import Constants from "../../common/constants/Constants"
import { WebPageParam } from "../../common/entities/PageParams"
import { WarrantyDialog } from "../dialog/WarrantyDialog"

@Builder
function TextContent(title: string, text: string, action?: () => void) {
  Button() {
    Row() {
      Text(title)
        .LeftText()
      if (!text) {
        Image($r('app.media.ic_public_arrow_right'))
          .width(Constants.FONT_SIZE_COMMON)
          .fillColor($r('app.color.reverse'))
      } else {
        Text(text)
          .RightText()
          .fontWeight(FontWeight.Bold)
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }
  .backgroundColor(Color.Transparent)
  .padding(Constants.PADDING_EDGE_DEFAULT)
  .onClick(action)
}

@Component
export struct TextContents {
  warrantyDialogController: CustomDialogController = new CustomDialogController({
    builder: WarrantyDialog(),
    autoCancel: false
  })

  @Consume('pageInfos') pageInfos: NavPathStack

  build() {
    Column() {
      Column() {
        TextContent('应用版本', AppConstants.VERSION + AppConstants.VER_DESC)
      }
      .gesture(
        TapGesture({
          count: 5
        }).onAction(() => {
          this.pageInfos.pushDestinationByName('DebugPage', null)
        })
      )
      TextContent('使用文档', '', () => {
        let param: WebPageParam = {
          title: '使用文档', url: 'https://docs.chenlvin.cc/cloudmusic/#/help'
        }
        this.pushWebPage(param)
      })
      TextContent('建议反馈', '', () => {
        let param: WebPageParam = {
          title: '建议反馈', url: 'https://www.wjx.cn/vm/PeLnYfc.aspx#'
        }
        this.pushWebPage(param)
      })
    }
    .padding({ top: Constants.PADDING_EDGE_DEFAULT, bottom: Constants.PADDING_EDGE_DEFAULT })
  }

  private pushWebPage(param: WebPageParam) {
    if(this.pageInfos.size() < 2) {
      this.pageInfos.pushPathByName('WebPage', param)
    } else {
      this.pageInfos.replacePathByName('WebPage', param)
    }
  }
}

@Component
export struct OtherContents {
  warrantyDialogController: CustomDialogController = new CustomDialogController({
    builder: WarrantyDialog(),
    autoCancel: false
  })

  @Consume('pageInfos') pageInfos: NavPathStack

  build() {
    Column() {
      TextContent('隐私政策', '', () => {
        let param: WebPageParam = {
          title: '隐私政策', url: 'https://docs.chenlvin.cc/cloudmusic/#/privacy'
        }
        this.pushWebPage(param)
      })
      TextContent('免责声明', '', () => {
        this.warrantyDialogController.open()
      })
    }
    .padding({ top: Constants.PADDING_EDGE_DEFAULT, bottom: Constants.PADDING_EDGE_DEFAULT })
  }

  private pushWebPage(param: WebPageParam) {
    if(this.pageInfos.size() < 2) {
      this.pageInfos.pushPathByName('WebPage', param)
    } else {
      this.pageInfos.replacePathByName('WebPage', param)
    }
  }
}

/**
 * 底部信息
 */
@Component
export struct Settings_Bottom {
  @Consume('pageInfos') pageInfos: NavPathStack

  build() {
    Column() {
      Text('云音汇 CloudMusic\n' +
        'For HarmonyOS NEXT\n' +
      '原作者 Chenlvin | 深度定制 By Handwer').BottomText()
    }
    .width('100%')
  }
}

@Extend(Text) function LeftText() {
  .fontSize(Constants.FONT_SIZE_COMMON)
  .fontWeight(FontWeight.Bold)
}

@Extend(Text) function RightText() {
  .fontSize(Constants.FONT_SIZE_COMMON)
}

@Extend(Text) function BottomText() {
  .lineHeight(20)
  .fontSize(12)
  .textAlign(TextAlign.Center)
  .onClick(() => {
    PasteboardUtil.setDataText('https://github.com/Chenlvin/CloudMusic-HarmonyOSNext')
    ToastUtil.showToast('已复制GitHub链接到剪贴板')
  })
}