import FileUtils from '../common/utils/file/FileUtils';
import { FileCard } from '../components/cards/FileCard';
import { BottomBarComponent } from '../components/play/BottomBarComponent';
import Constants from '../common/constants/Constants';
import { resourceManager } from '@kit.LocalizationKit';
import { StorageConstants } from '../common/constants/StorageConstants';
import { DialogUtil, LogUtil, PickerUtil, ToastUtil } from '@pura/harmony-utils';

/**
 * 缓存管理页
 * DownloadPage
 */
const TAG = '[CachedPage] '

@Component
export struct CachedPage {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @StorageProp(StorageConstants.BREAKPOINT) breakpoint: string = 'sm'
  @State searchKeyword: string = ''
  @State fileList: string[] = []
  @State filteredList: Array<string> = new Array()
  @State isSorted: boolean = false
  @State isSelecting: boolean = false
  @State selectedFiles: string[] = []
  private originalOrderList: string[] = []

  menus: NavigationMenuItem[] = [
    {
      value: 'Search',
      icon: $r('app.media.ic_public_search_filled'),
      action: () => {
        this.getUIContext().getFocusController().requestFocus('search')
      }
    },
    {
      value: 'Upload',
      icon: $r('app.media.ic_public_upload_filled'),
      action: () => {
        this.handleUpload()
      }
    },
    {
      value: 'Helper',
      icon: $r('app.media.ic_public_help'),
      action: () => {
        DialogUtil.showConfirmDialog({
          title: '上传文件',
          message: '支持上传本机音频文件至缓存目录\n' +
            '支持格式为.mp3 .flac\n\n' +
            '文件名格式：歌手 - 歌名.mp3\n\n' +
            '文件名格式不正确会导致无法识别\n' +
            '在线播放时，将自动匹配文件名调取本地文件进行播放'
        })
      }
    }
  ]

  async aboutToAppear(): Promise<void> {
    this.refreshFileList()
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        Column() {
          Column() {
            Grid() {
              GridItem() {
                Search({
                  placeholder: '搜索文件',
                  icon: '/resources/base/media/ic_public_search_filled.svg'
                })
                  .id('search')
                  .height(Constants.HEIGHT_SELECT)
                  .width('100%')
                  .searchButton('搜索')
                  .onChange((value) => {
                    if(value == '') {
                      this.filteredList = []
                      this.searchKeyword = ''
                    }
                  })
                  .onSubmit((value) => {
                    this.searchKeyword = value
                    this.handelSearch()
                  })
              }
              GridItem() {
                if (this.fileList.length > 0) {
                  Row() {
                    Text(this.isSelecting ? `已选 ${this.selectedFiles.length} 项` : `共 ${this.fileList.length} 首歌曲`)
                      .fontSize(Constants.FONT_SIZE_COMMON)
                    Row({ space: 20 }) {
                      if(!this.isSelecting) {
                        Image($r('app.media.ic_files_name_drive'))
                          .width(Constants.SIZE_ICON_BUTTON_BAR)
                          .aspectRatio(1)
                          .fillColor(this.isSorted ? $r('app.color.blue') : Color.Gray)
                          .onClick(() => {
                            this.isSorted = !this.isSorted
                            this.fileList = this.getSortedList(this.fileList)
                            if (this.searchKeyword) {
                              this.filteredList = this.getSortedList(this.filteredList)
                            }
                          })
                      } else {
                        if(this.selectedFiles.length > 0) {
                          Image($r('app.media.ic_public_delete'))
                            .width(Constants.SIZE_ICON_BUTTON_BAR)
                            .aspectRatio(1)
                            .fillColor(Color.Gray)
                            .onClick(() => {
                              this.handleDelete()
                            })
                          Image($r('app.media.ic_public_folder'))
                            .width(Constants.SIZE_ICON_BUTTON_BAR)
                            .aspectRatio(1)
                            .fillColor(Color.Gray)
                            .onClick(() => {
                              FileUtils.saveFile(this.selectedFiles)
                            })
                        }
                        CheckboxGroup({ group: 'fileCard' })
                          .width(Constants.SIZE_ICON_BUTTON_BAR - 5)
                          .height(Constants.SIZE_ICON_BUTTON_BAR - 5)
                      }

                      Image($r('app.media.ic_gallery_material_select_checkbox'))
                        .width(Constants.SIZE_ICON_BUTTON_BAR)
                        .aspectRatio(1)
                        .fillColor(this.isSelecting ? $r('app.color.blue') : Color.Gray)
                        .onClick(() => {
                          animateTo({ duration: 100, curve: Curve.EaseInOut }, () => {
                            this.isSelecting = !this.isSelecting
                            this.selectedFiles = []
                          })
                        })
                    }
                    .height(30)
                  }
                  .justifyContent(FlexAlign.SpaceBetween)
                  .width('100%')
                }
                else {
                  Text('文件沙箱目录为空').width('100%').textAlign(TextAlign.Center).padding({ left: 30, right: 30, top: 10 })
                }
              }

              GridItem() {
                GridRow({ columns: { xs: 1, sm: 1, md: 1, lg: 2, xl: 2 } }) {
                  ForEach(this.searchKeyword ?
                  this.getSortedList(this.filteredList) :
                  this.getSortedList(this.fileList),
                    (item: string, index: number) => {
                    GridCol() {
                      Row({ space: 5 }) {
                        FileCard({
                          fileName: item,
                          list: this.fileList
                        })
                          .layoutWeight(1)
                        if(this.isSelecting) {
                          this.CardCheckBox(item)
                        }
                      }
                      .width('100%')
                      .padding({ bottom: Constants.PADDING_EDGE_DEFAULT })
                    }
                  })
                }
              }
              .width('100%')

              GridItem()
                .height(px2vp(this.bottomRectHeight) + Constants.HEIGHT_MINI)
            }
            .edgeEffect(EdgeEffect.Spring)
            .scrollBar(BarState.Off)
            .rowsGap(10)
            .columnsGap(10)
            .columnsTemplate('1fr')
            .layoutDirection(GridDirection.Column)
            .backgroundColor($r('sys.color.background_secondary'))
            .height('100%')
            .width('100%')
            .padding({ left: 10, right: 10 })
            .layoutWeight(1)
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
          }
          .justifyContent(FlexAlign.Center)
          .layoutWeight(1)
          .width('100%')
        }
        .width('100%')
        .height('100%')

        if(this.breakpoint !== 'lg') {
          BottomBarComponent()
            .padding(Constants.PADDING_EDGE_DEFAULT)
            .backgroundColor(Color.Transparent)
        }
      }
      .backgroundColor($r('sys.color.background_secondary'))
      .height('100%')
    }
    .title('缓存')
    .menus(this.menus)
    .backgroundColor($r('sys.color.background_secondary'))
  }

  private handelSearch() {
    try {
      if (this.searchKeyword.trim() === '') {
        this.filteredList = [...this.fileList]
        return
      }
      const keyword = this.searchKeyword.trim().toLowerCase()
      this.filteredList = this.getSortedList( // 保持当前排序状态
        this.fileList.filter(string =>
        string.toLowerCase().includes(keyword))
      )
    } catch (e) {
      ToastUtil.showToast('搜索时出错')
      LogUtil.error(TAG + 'Error while handelSearch: ' + e.message)
    }
  }

  private async refreshFileList() {
    this.fileList = await FileUtils.getFileName()
    this.originalOrderList = [...this.fileList]
    this.isSelecting = false
    this.selectedFiles = []
  }

  private async handleUpload() {
    PickerUtil.selectDocument({
      maxSelectNumber: 99,
      fileSuffixFilters: ['音频 | .mp3,.flac']
    }).then((uris) => {
      FileUtils.saveFilesToDirectory(uris).then(async (result) => {
        if(result) {
          ToastUtil.showToast('上传成功')
          await this.refreshFileList()
        }
      })
    })
  }

  private getSortedList(list: string[]): string[] {
    return this.isSorted ?
    [...list].sort((a, b) => a.localeCompare(b)) :
    this.originalOrderList.filter(f => list.includes(f))
  }

  private handleDelete() {
    DialogUtil.showPrimaryDialog({
      title: '确认',
      message: `是否删除选中的 ${this.selectedFiles.length} 个文件?`,
      primaryButton: "取消",
      secondaryButton: {
        value: '删除',
        fontColor: Color.Red,
        action: async () => {
          FileUtils.deleteFile(this.selectedFiles).then(async () => {
            await this.refreshFileList()
          })
        }
      }
    })
  }

  @Builder CardCheckBox(name: string) {
    Checkbox({ group: 'fileCard' })
      .shape(CheckBoxShape.ROUNDED_SQUARE)
      .width(Constants.SIZE_ICON_BUTTON_BAR)
      .aspectRatio(1)
      .onChange((value) => {
        if(value) {
          animateTo({ duration: 100, curve: Curve.Ease }, () => {
            this.selectedFiles.push(name)
          })
        } else {
          animateTo({ duration: 100, curve: Curve.Ease }, () => {
            this.selectedFiles = this.selectedFiles.filter(item => item !== name)
          })
        }
      })
  }
}