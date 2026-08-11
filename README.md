# BowlingWesternRealityKit DocC Tutorial

RealityKit, ARKit, Vision을 사용해 볼링 투구 촬영 중 볼러는 원본 그대로 보존하고, 볼러를 제외한 주변 배경을 젠틀맨리그 콘셉트의 서부극 장면으로 실시간 변환한 뒤 녹화하는 과정을 다루는 DocC 튜토리얼입니다.

## Visual Direction

대표 스타일은 `GentlemanLeague_image.png`를 기준으로 합니다.

- 오렌지 석양과 강한 역광
- 목조 살룬, 오래된 간판, 서부 마을 건물
- 볼링 레인이 마을 중앙 도로처럼 이어지는 깊은 원근감
- 양쪽 인물 또는 실루엣이 레인을 향해 서 있는 대결 구도
- 검은 잉크 라인과 거친 질감이 살아 있는 그래픽 노블풍 렌더링
- 볼링공, 핀, 레인, `STRIKE YOUR LEGEND` 같은 문구가 서부극 소품과 자연스럽게 결합된 톤
- 볼러의 몸과 투구 동작은 원본 영상 그대로 유지하고, 뒤쪽 볼링장 배경만 서부극 장면으로 교체하는 합성 방식

## Requirements

- Xcode 15 이상
- iOS 17 이상 또는 visionOS 1 이상
- RealityKit, ARKit, Vision 사람 세그멘테이션, ReplayKit 기본 이해
- 카메라 사용 가능한 실기기 권장
- GitHub Pages 정적 배포용 Public Repository: `2026TechMap_tutorial`

## Build DocC

```bash
xcrun docc convert Sources/BowlingWesternRealityKit.docc \
  --fallback-display-name BowlingWesternRealityKit \
  --fallback-bundle-identifier com.gentlemanleague.BowlingWesternRealityKit \
  --fallback-bundle-version 1.0.0 \
  --transform-for-static-hosting \
  --hosting-base-path 2026TechMap_tutorial \
  --output-path docs
```

## Preview Locally

```bash
xcrun docc preview Sources/BowlingWesternRealityKit.docc
```

## Deploy to GitHub Pages

1. GitHub에서 Public Repository `2026TechMap_tutorial`을 만듭니다.
2. 이 프로젝트를 `main` 브랜치로 push합니다.
3. Repository Settings > Pages에서 Source를 `GitHub Actions`로 선택합니다.
4. `Deploy DocC to GitHub Pages` workflow가 완료되면 아래 주소에서 튜토리얼을 확인합니다.

```text
https://<your-github-username>.github.io/2026TechMap_tutorial/tutorials/bowlingwesternrealitykit
```
