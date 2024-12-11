/**
 * Author: Meng
 * Date: 2024/12/06
 * Modify: 2024/12/06
 * Desc: Insta 360 相机工具类
 */

/**
 * 获取 相机信息
 * @returns {{connectType: number 0 wifi，1 usb
 * , sdCardTotalSpace: number,SD卡总大小
 * isCharging: boolean, 是否充电中
 * status: number, 0未连接，1 已连接
 * batteryLevel: number,电量
 * sdCardFreeSpace: number SD卡可用空间
 * }}
 */
export async function getCameraInfo() {

}

/**
 * 格式化 SD卡
 *  0格式化失败（SD卡异常或其他原因）1成功  2设备未连接 3格式化失败
 */
export function formatStorage() {

}

export function getCameraCache() {

}

/**
 * 连拍模式
 *  setting [{type:0 拍照  1 录像,content : 拍摄内容描述}]
 *  callback(是否成功  返回信息json :[{type content path}]
 *   int type;//0 拍照 1 录像
 *     String content;//拍照内容 描述
 *     String path;//本地路径
 *  )
 */
export function startContinuousShooting() {

}