# StempCaseStudy

Recorte de estudo de caso do app **Stemp** (Apple Developer Academy). Sem API, sem login, sem Airtable.

## O que tem
- **Desafios** (1ª aba): formulário que substitui o calendário. Cria Challenge, Workshop, Apresentação, Bridge, Integration, Eventos ou Reflection, com data/hora, descrição (markdown), ícone, cor, material de apoio e entregáveis com prazo.
- **Dashboard**: layout original (Frequência, Situação atual, Próximo evento). Frequência é fictícia; o próximo evento vem dos desafios criados.
- **Eventos**: lista, badge "Novo", sheet de detalhes, igual ao original. Pressione e segure um card para removê-lo.
- **Perfil**: placeholder "Este projeto é para fins de estudo de caso".
- Menu `...` na aba Desafios: carregar exemplos fictícios / apagar todos.

## Como montar no Xcode
1. File > New > Project > iOS App, nome `StempCaseStudy`, SwiftUI, **iOS 18+** (o `symbolEffect(.wiggle)` do original exige iOS 18).
2. Apague o `ContentView.swift` e o `...App.swift` gerados e arraste as pastas `App`, `Shared`, `Support` e `Views` para o projeto (marque "Copy items" e o target do app).
3. Rode. Use "Carregar exemplos fictícios" para popular tudo.

## Preparando o Widget (próximo passo)
1. Em **Signing & Capabilities** do app, adicione **App Groups** e crie, por exemplo, `group.com.seunome.stempcasestudy`.
2. Troque `appGroupID` em `Shared/EventStorage.swift` pelo mesmo valor.
3. File > New > Target > **Widget Extension**. Adicione o mesmo App Group nele.
4. Marque o target do Widget (File Inspector > Target Membership) nos 4 arquivos de `Shared/`: `EventKind`, `EventDetail`, `EventStorage`, `ColorExtension`.
5. No `TimelineProvider` do Widget:

```swift
let events = EventStorage.upcoming(EventStorage.loadEvents())
let next = events.first          // EventDetail
let deadline = next?.nextDeliverable   // Deliverable? (título, dueDate, url)
```

O app já chama `WidgetCenter.shared.reloadAllTimelines()` a cada criação/remoção.

## Observações
- As cores `bg950`, `bg900`, `gradientStart` vêm do Assets do projeto original e não estavam no código; em `Support/Theme.swift` estão aproximadas.
- Sem o App Group configurado o app funciona, mas o Widget não enxerga os dados.
