/**
 * Author: Meng
 * Date: 2024/11/15
 * Modify: 2024/11/15
 * Desc: 调试弹窗
 */
import { sensor } from '@kit.SensorServiceKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Component
export default struct Debug {
  minCount = 6;
  duration = 8;
  scope = 10;
  count = 0;
  lastTime = 0;
  @State visible: boolean = false;

  aboutToAppear(): void {
    this.onSensorListener();
  }

  getSensors() {
    sensor.getSensorList((error: BusinessError, data: Array<sensor.Sensor>) => {
      if (error) {
        console.info('getSensorList failed');
      } else {
        for (let i = 0; i < data.length; i++) {
          console.info(JSON.stringify(data[i]));
        }
      }
    });
  }

  onSensorListener() {
    sensor.on(sensor.SensorId.ACCELEROMETER, (data: sensor.AccelerometerResponse) => {
      console.info("accelerometer x: " + data.x + ", y: " + data.y + ", z: " + data.z);
      const max = Math.max(Math.abs(data.x), Math.abs(data.y), Math.abs(data.z));
      this.onHandlerResult(max);
    }, { interval: 100000000 });
    // sensor.off(sensor.SensorId.ACCELEROMETER); // 取消监听
  }

  onHandlerResult(num: number) {
    if (num > this.scope && !this.visible) {
      this.count += 1;
      if (this.count > this.minCount && !this.visible) {
        this.visible = true;
        this.count = 0;
      }
    }
  }

  build() {
    Stack() {
      Text('Debug').fontColor(Color.White).backgroundColor(Color.Orange)
    }
  }
}