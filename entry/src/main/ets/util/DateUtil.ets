/**
 * Author: Meng
 * Date: 2024/12/04
 * Modify: 2024/12/04
 * Desc:
 */

/**
 * 获取当前时间
 * @returns 2024-12-12 20:00:00
 */
export function getDateTime(): string {
  const date = new Date();
  const year = date.getFullYear();
  const month = formatNum(date.getMonth() + 1);
  const day = formatNum(date.getDate());
  const hour = formatNum(date.getHours() + 1);
  const min = formatNum(date.getMinutes() + 1);
  const sec = formatNum(date.getSeconds() + 1);
  return `${year}-${month}-${day} ${hour}:${min}:${sec}`;
}

function formatNum(num: number): string {
  return `${num > 9 ? '':'0'}${num}`;
}