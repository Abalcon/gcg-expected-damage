# GCG Calculator Collection

걸카페건 각종 계산기

## 기능

팬텀 뱅가드 시즌별 필요 충전량 계산

모의전 종목별 점수 계산

대미지 배율 기댓값 계산 (beta)
- 무기 사격 DPS 배율
- 스킬 대미지 배율

### 실제 대미지 계산 방법

무기 사격 대미지
- 유닛 공격력 * 무기 사격 DPS 배율 * 무기 사격 시간 * 대미지 버프 * 실신 여부 보정치 * (1 + 상대 피격 대미지 디버프)

스킬 대미지
- 유닛 공격력 * 스킬 배율 * 스킬 대미지 배율 * 실신 여부 보정치 * 대미지 버프 * (1 + 상대 피격 대미지 디버프)

#### 용어 설명

대미지 버프
- 1 + 부여 대미지 증가 합연산 수치 

실신 여부 보정치
| 실신치/브레이크 여부 | 기본값 수치 |
| --------------- | -------- |
| 실신치 없음        | 1        |
| 실신치 있음        | 0.5      |
| 실신치 있음, 브레이크| 1.5      |

상대 피격 대미지 디버프
- 피격 대미지 증가 합연산 수치
