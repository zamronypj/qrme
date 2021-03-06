(*!------------------------------------------------------------
 * [[APP_NAME]] ([[APP_URL]])
 *
 * @link      [[APP_REPOSITORY_URL]]
 * @copyright Copyright (c) [[COPYRIGHT_YEAR]] [[COPYRIGHT_HOLDER]]
 * @license   [[LICENSE_URL]] ([[LICENSE]])
 *------------------------------------------------------------- *)
unit bootstrap;

interface

uses

    fano;

type

    TAppServiceProvider = class(TDaemonAppServiceProvider)
    protected
        function buildAppConfig(const container : IDependencyContainer) : IAppConfiguration; override;
        function buildDispatcher(
            const ctnr : IDependencyContainer;
            const routeMatcher : IRouteMatcher;
            const config : IAppConfiguration
        ) : IDispatcher; override;
    public
        procedure register(const container : IDependencyContainer); override;
    end;

    TAppRoutes = class(TRouteBuilder)
    public
        procedure buildRoutes(
            const container : IDependencyContainer;
            const router : IRouter
        ); override;
    end;

implementation

uses
    sysutils

    (*! -------------------------------
     *   controllers factory
     *----------------------------------- *)
    {---- put your controller factory here ---},
    HomeControllerFactory,
    QrCodeGeneratorControllerFactory,
    PngQrCodeGeneratorControllerFactory,
    SvgQrCodeGeneratorControllerFactory,
    AuthControllerFactory,
    LoginControllerFactory,
    AuthOnlyMiddlewareFactory,
    NotLoggedInControllerFactory,
    DashboardControllerFactory,
    LoginViewFactory,

    BottomJsViewPartialFactory,
    TopCssViewPartialFactory,
    TopBarViewPartialFactory,
    LeftMenuViewPartialFactory,
    BreadcrumbViewPartialFactory,
    FooterViewPartialFactory,
    FullViewPartialFactory,
    MainViewPartialFactory;



    function TAppServiceProvider.buildAppConfig(const container : IDependencyContainer) : IAppConfiguration;
    begin
        container.add(
            'config',
            TJsonFileConfigFactory.create(
                getCurrentDir() + '/config/config.json'
            )
        );
        result := container['config'] as IAppConfiguration;
    end;

    function TAppServiceProvider.buildDispatcher(
        const ctnr : IDependencyContainer;
        const routeMatcher : IRouteMatcher;
        const config : IAppConfiguration
    ) : IDispatcher;
    begin
        ctnr.add('appMiddlewares', TMiddlewareListFactory.create());

        ctnr.add(
            'sessionManager',
            TJsonFileSessionManagerFactory.create(
                config.getString('session.name'),
                config.getString('session.dir')
            )
        );

        ctnr.add(
            GuidToString(IDispatcher),
            TSessionDispatcherFactory.create(
                ctnr['appMiddlewares'] as IMiddlewareLinkList,
                routeMatcher,
                TRequestResponseFactory.create(),
                ctnr['sessionManager'] as ISessionManager,
                (TCookieFactory.create()).domain(config.getString('cookie.domain')),
                config.getInt('cookie.maxAge')
            )
        );
        result := ctnr[GuidToString(IDispatcher)] as IDispatcher;
    end;

    procedure TAppServiceProvider.register(const container : IDependencyContainer);
    begin
        {$INCLUDE Dependencies/dependencies.inc}
    end;

    procedure TAppRoutes.buildRoutes(
        const container : IDependencyContainer;
        const router : IRouter
    );
    begin
        {$INCLUDE Routes/routes.inc}
    end;
end.
