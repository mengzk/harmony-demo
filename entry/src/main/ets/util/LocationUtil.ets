/**
 * Author: Meng
 * Date: 2024/12/03
 * Modify: 2024/12/03
 * Desc: 获取定位/选择位置
 */
import { common } from '@kit.AbilityKit';
import { sceneMap } from '@kit.MapKit';
import { geoLocationManager } from '@kit.LocationKit';
import { BusinessError } from '@kit.BasicServicesKit';

export interface LatLng {
  code?: number;
  latitude: number;
  longitude: number;
  speed?: number; // 速度 m/s
  altitude?: number; // 高度
  accuracy?: number; // 精度 单位米
  direction?: number; // 方向
  address?: string;
  name?: string;
  time?: number;
}

let LocationCache: LatLng = { latitude: 0, longitude: 0, time: 0 }; // 缓存
const interval = 30000; // 30s内不再获取

/**
 * 选择位置
 */
export function chooseAddress(context: common.UIAbilityContext): Promise<string> {
  let locationChoosingOptions: sceneMap.LocationChoosingOptions = {
    location: {
      latitude: 39.92194051376904, longitude: 116.3971836796932
    },
    // language: 'zh_CN',
    // 展示搜索控件
    searchEnabled: true,
    // 展示附近Poi
    showNearbyPoi: true
  };
  return sceneMap.chooseLocation(context, locationChoosingOptions)
    .then((data) => {
      console.info("ChooseLocation", "Succeeded in choosing location.");
      return ''
    })
    .catch((err: BusinessError) => {
      // 1002600003 没权限
      console.warn(`-----> chooseLocation err: ${err.code}, ${err.message}`);
      return ''
    });
}

/**
 * 获取当前定位
 */
export async function getCurLocation(context: common.UIAbilityContext, cache?: boolean): Promise<LatLng> {
  return new Promise((resolve) => {

    if (cache && Date.now() - (LocationCache.time || 0) < interval) {
      resolve(LocationCache);
      return;
    }

    let requestInfo: geoLocationManager.LocationRequest = {
      'priority': geoLocationManager.LocationRequestPriority.FIRST_FIX,
      'scenario': geoLocationManager.LocationRequestScenario.UNSET,
      'timeInterval': 1,
      'distanceInterval': 0,
      'maxAccuracy': 0
    };
    let locationChange = (res: geoLocationManager.Location): void => {
      console.log('locationChanger: data: ' + JSON.stringify(res));
      geoLocationManager.off('locationChange', locationChange);
      const ads: LatLng = {
        latitude: res.latitude,
        longitude: res.longitude,
        altitude: res.altitude,
        accuracy: res.accuracy,
        speed: res.speed,
        code: 0
      }
      LocationCache = ads;
      resolve(ads)
    };
    try {
      geoLocationManager.on('locationChange', requestInfo, locationChange);
    } catch (err) {
      console.warn("-----> chooseLocation err:" + JSON.stringify(err)); // 201没权限；3301000位置服务不可用；401参数错误
      resolve({
        latitude: 0, longitude: 0, code: -1
      })
    }
  });
}
