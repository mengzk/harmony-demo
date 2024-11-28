export function getSeparatorPhone(phone: string | undefined, encrypt = false): string {
  if (!phone) {
    return ''
  }
  const purePhone: string = phone?.replace(/\D/g, '');
  const length = purePhone?.length;
  if (length <= 3) {
    return purePhone;
  } else if (length <= 7) {
    return purePhone.replace(/(\d{3})(\d{0,4})/, '$1 $2');
  } else {
    if (encrypt) {
      return purePhone.replace(/(\d{3})\d*(\d{4})/, '$1 **** $2 ');
    }
    return purePhone.replace(/(\d{3})(\d{4})/, '$1 $2 ');
  }
}

//手机号加密*
export function maskMobile(phone: string) {
  if (phone && phone.length > 10) {
    return phone.slice(0, 3) + ' **** ' + phone.slice(7, 11)
  }
  return phone
}
export function goToMap() {}

/**
 * 解析地址
 * @param url
 */
export function parseQuery(url?: string): Object {
  let options: Record<string, string> = {};
  if (!url) {
    return options;
  }
  try {
    let newUrl = decodeURIComponent(url)
    let paramStr = ''
    if (newUrl.indexOf("?") !== -1) {
      let reg = /[\u4e00-\u9fa5]+/g;

      let arr = newUrl.substring(newUrl.indexOf("?") + 1).split("&");
      for (let i= 0; i < arr.length; i++) {
        let items = arr[i].split("=");
        const key = items[0];
        const value = items[1];
        options[key] = value;

        let newKey = key;
        if (key.match(reg)) {
          newKey = encodeURIComponent(key);
        }
        let newValue = value
        if (value.match(reg)) {
          newValue = encodeURIComponent(newValue || '');
        }
        paramStr += `&${newKey}=${newValue}`;
      }
    }

    if (paramStr.length > 0) {
      paramStr = paramStr.slice(0, -1);
      let base = url.split('?')
      newUrl = `${base[0]}?${paramStr}`;
    }
    options.url = newUrl
  } catch (e) {
    console.log('parseQuery ----->', JSON.stringify(e));
  }
  return options;
}