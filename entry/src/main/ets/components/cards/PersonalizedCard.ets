import Constants from "../../common/constants/Constants"
import { PlayListPageParam } from "../../common/entities/PageParams"
import { PersonalListItem } from "../../common/entities/Personalized"

@Component
export struct PersonalizedCard {
  @State item: PersonalListItem = {
    id: 0,
    type: 0,
    name: "",
    copywriter: "",
    picUrl: "",
    playCount: 0,
    trackCount: 0
  }
  @Consume('pageInfos') pageInfos: NavPathStack

  build() {
    Row({ space: 10 }) {
      Image(this.item.picUrl)
        .aspectRatio(1)
        .height(80)
        .borderRadius(Constants.RADIUS_IMG)
        .shadow(ShadowStyle.OUTER_DEFAULT_MD)

      Column({ space: 5 }) {
        Text(this.item.name)
          .fontColor($r('app.color.reverse'))
          .fontWeight(FontWeight.Bold)
          .fontSize(16)
          .width('100%')
          .textAlign(TextAlign.Start)
          .lineHeight(20)
          .maxLines(3)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        if(this.item.copywriter) {
          Text(this.item.copywriter)
            .reasonText()
        }
      }
      .height(80)
      .layoutWeight(1)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .padding(Constants.PADDING_EDGE_DEFAULT)
    .width(250)
    .clickEffect({ level: ClickEffectLevel.HEAVY, scale: 0.9 })
    .onClick(() => {
      let param: PlayListPageParam = {
        playList: {
          userId: 0,
          id: this.item.id,
          name: this.item.name,
          playCount: this.item.playCount,
          coverImgUrl: this.item.picUrl,
          trackCount: this.item.trackCount,
          subscribedCount: 0,
          subscribed: false,
          creator: {
            userId: 0,
            nickname: '推荐歌单'
          }
        },
        isShowHeart: false,
        useTimestamp: false
      }
      if(this.pageInfos.size() < 2) {
        this.pageInfos.pushPathByName('PLayListPage', param, true)
      } else {
        this.pageInfos.replacePathByName('PLayListPage', param, true)
      }
    })
  }
}

@Extend(Text) function reasonText() {
  .alignSelf(ItemAlign.Start)
  .fontColor('#ffff3232')
  .fontSize(10)
  .padding(2)
  .backgroundColor('#ffffd2d2')
  .borderRadius(5)
}