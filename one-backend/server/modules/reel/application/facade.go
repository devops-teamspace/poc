package application

import (
	"xrspace.io/server/core/arch/application"
	"xrspace.io/server/core/arch/domain/eventbus"
	"xrspace.io/server/modules/reel/application/command"
	"xrspace.io/server/modules/reel/application/define"
	"xrspace.io/server/modules/reel/application/query"
)

var _ application.IFacade = (*Facade)(nil)

type Facade struct {
	*application.AbsFacade

	dep      define.Dependency
	EventBus eventbus.IEventBus
}

func NewFacade(dep define.Dependency) *Facade {
	f := &Facade{
		AbsFacade: application.NewAbsFacade(),
		dep:       dep,
		EventBus:  dep.EventBus,
	}

	f.RegisterUseCase(&command.CreateReelCommand{}, command.NewCreateReelUseCase(dep))
	f.RegisterUseCase(&command.DeleteReelCommand{}, command.NewDeleteReelUseCase(dep))
	f.RegisterUseCase(&command.PublishReelCommand{}, command.NewPublishReelUseCase(dep))
	f.RegisterUseCase(&query.ListReelQuery{}, query.NewListReelUseCase(dep))

	return f
}
