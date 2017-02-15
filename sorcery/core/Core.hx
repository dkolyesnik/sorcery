/**
 * Created by Dmitriy Kolesnik on 27.08.2016.
 */
package sorcery.core;
import sorcery.core.interfaces.ICore;
import sorcery.core.interfaces.ICoreFactory;
import sorcery.core.interfaces.IBundle;
import sorcery.core.interfaces.ICorePluginManager;
import sorcery.core.interfaces.IEntity;
import sorcery.core.interfaces.IEntityGroup;
import sorcery.core.interfaces.IEntityRoot;
import sorcery.core.interfaces.INotificator;
import sorcery.core.interfaces.ITime;
import haxecontracts.Contract;
import haxecontracts.HaxeContracts;



class Core implements ICore implements HaxeContracts
{
    public var root(get, null) : IEntityRoot;
    public var time(get, null) : ITime;
	
    var notificator(get, null) : INotificator;
	var factory(get, null) : ICoreFactory;

	private var _setup:CoreSetup;
    
    public function new(setup:CoreSetup)
    {
		Contract.requires(setup != null);
		
		_setup = setup;
		
		_initialize();
    }
    
    function _initialize() : ICore
    {
		if (_setup.factory == null)
			factory = new CoreFactory();
		else
			factory = _setup.factory;
        
        factory.initialize(this);

        _createAll();
		
		var bundlesEntity = allocateEntity("bundles");
		root.addChild(bundlesEntity);
		for (bundle in _setup._bundles)
		{
			//adding as a child, so bundle will have core access
			bundlesEntity.addChild(bundle);
		}
        
		for (bundle in _setup._bundles)
		{
			//bundles asks parent if required bundles are added
			bundle.initialize();
		}
		
        return this;
    }
    
    private function _createAll() : Void
    {
        notificator = factory.createNotificator();
        time = factory.createTime();
        root = factory.createRoot();
    }
    
    public function allocateEntity(?name:String) : IEntity
    {
        var ent = factory.allocateEntity();
		if(name != null)
			ent.setName(name);
		return ent;
    }
    
    public function wrapInGroup(entity:IEntity) : IEntity
    {
        return factory.wrapInGroup(entity);
    }
    
    public function log(msg : String) : Void
    {
        trace(msg);
    }
	
	public function get_root():IEntityRoot
	{
		return root;
	}
	public function get_time():ITime
	{
		return time;
	}
	public function get_notificator():INotificator
	{
		return notificator;
	}
	public function get_factory():ICoreFactory
	{
		return factory;
	}
}
