# CookM2 - 烤冷面传奇 项目进度

## 项目概述

Godot 4.6 烹饪游戏，基于"Shawarma Legend"玩法，制作烤冷面并完成订单。

## 核心玩法流程

1. **准备食材** — 点击备料区原料，飞出到对应位置
2. **烹饪制作** — 铁板上翻面、加料、卷起、切段
3. **装盒出餐** — 切好的冷面拖入纸盒，拖给客人完成订单
4. **循环** — 每份订单完成后可重新制作

## 已完成功能

### 备料系统（4个准备区 + 母鸡）
- **面区**（NoodleZone）：点击→飞出到铁板 CookPos，显示面饼贴图
- **菜区**（OnionZone）：点击3次切碎→飞出到食材盒
- **肉区**（SausageZone）：点击→飞到铁板 SausagePos→3秒烤熟→点击飞入面饼
- **酱区**（ChiliZone）：点击→飞到食材盒
- **母鸡**（ChickenPos）：点击→鸡蛋飞出到食材盒格子

### 食材盒（IngredientBox）
- 3个格子：鸡蛋、洋葱碎、辣酱
- 初始隐藏，点击对应备料后解锁
- 点击后飞到铁板 CookPos 并显示对应贴图

### 铁板（Grill）
- 点击切段（5次）
- 上滑翻面、下滑卷起
- 状态贴图：NoodleSprite（面饼）、EggSprite（鸡蛋）
- CookPos 作为烹饪位置标记

### 纸盒系统
- 点击纸盒堆→飞出到 BoxSlot0/1/2 位置
- 冷面拖到空纸盒→纸盒装满
- 有面纸盒可拖给客人完成订单

### 贴图系统
- NoodleSprite（浅褐色矩形）— 面饼
- EggSprite（浅黄色矩形）— 鸡蛋
- SausageSprite（红色→橙色）— 烤肠（熟后变色）

### 其他
- Camera2D 确保鼠标点击检测正常
- 所有交互使用 `_input()` + `_is_mouse_over()` 手动碰撞检测
- 每轮结束后备料和铁板自动重置

## 当前问题 / 待修复

- 烤肠烤熟后点击检测区域已扩大（120x60），需继续测试
- 第二轮后某些情况下烤肠可能无法点击

## 文件结构

```
cook-m-2/
├── scenes/
│   ├── main.tscn              — 主场景
│   ├── grill.tscn             — 铁板场景
│   ├── box.tscn               — 纸盒场景
│   ├── box_stack.tscn         — 纸盒堆场景
│   ├── noodle_drag_item.tscn  — 拖拽冷面场景
│   ├── customers/
│   │   └── customer.tscn      — 客人场景
│   └── prep_items/            — 备料场景
│       ├── noodle_item.tscn
│       ├── chicken_item.tscn
│       ├── onion_block_item.tscn
│       ├── sausage_raw_item.tscn
│       ├── chili_barrel_item.tscn
│       ├── egg_fill_item.tscn
│       ├── onion_fill_item.tscn
│       └── chili_fill_item.tscn
├── scripts/
│   ├── main.gd                — 主逻辑
│   ├── grill.gd               — 铁板交互
│   ├── clickable_item.gd      — 可点击物品基类
│   ├── fillable_item.gd       — 可填充物品
│   ├── choppable_item.gd      — 可切碎物品
│   ├── box.gd                 — 纸盒逻辑
│   ├── box_stack.gd           — 纸盒堆逻辑
│   ├── noodle_drag_item.gd    — 冷面拖拽
│   ├── draggable_item.gd      — 可拖拽物品基类
│   └── customers/
│       └── customer.gd        — 客人行为
├── resources/
│   └── noodle_dish.gd         — 冷面数据模型
└── project.godot
```

## 烹饪状态流程

```
面饼 → 鸡蛋 → 蛋摊(2s) → 翻面 → (加洋葱/辣酱/烤肠) → 卷起 → 切段(5次) → 装盒 → 给客人
```

## Git 仓库

https://github.com/stitchohana/KaoLengMian.git
