const colors = [
  '#3478F6',
  '#FF7D00',
  '#06C725',
]

interface PersonProps{
  headPic?:string
  avatarImg?:string
  accountName?:string
  accountNo?:string
}

export  interface AvatarItem {
  url:string |null
  name:string|null
  color:string|null
}

class AvatarUtil {

  getAvatar = (person:PersonProps, needRandom = false) => {
    let avatar = person?.headPic ?? person?.avatarImg
    let name = person?.accountName ?? ''
    let result:AvatarItem = {url: avatar||'', name: null, color: null}
    if (!avatar) {
      if (!!name) {
        result.name = name.length > 2 ? name.substring(name.length - 2, name.length) : name
      }
      let no:string = person?.accountNo?.replace(/[a-zA-Z]*/g, '')||""
      let index = needRandom ? random(colors.length) : Number(no ?? 0) % colors.length
      result.color = colors[index]
    }
    return result
  }
}

export const avatarUtil = new AvatarUtil()

// 生成随机数 0 ~ number 之间的整数, 不包括number
export function random(number:number) {
  return parseInt(Math.random() * number+'')
}
